
import FungibleToken from "../../contracts/FungibleToken.cdc"
import KiwiToken from "../../contracts/KiwiToken.cdc"
import PrivateReceiverForwarder from "../../contracts/PrivateReceiverForwarder.cdc"

/// This transaction adds a Vault, a private receiver forwarder
/// a balance capability, and a public capability for the receiver

transaction {

    prepare(signer: AuthAccount) {
        if signer.getCapability<&PrivateReceiverForwarder.Forwarder>(PrivateReceiverForwarder.PrivateReceiverPublicPath).check() {
            // private forwarder was already set up
            return
        }

        if signer.borrow<&KiwiToken.Vault>(from: KiwiToken.VaultStoragePath) == nil {
            // Create a new KiwiToken Vault and put it in storage
            signer.save(
                <-KiwiToken.createEmptyVault(),
                to: KiwiToken.VaultStoragePath
            )
        }

        signer.link<&{FungibleToken.Receiver}>(
            /private/kiwiTokenReceiver,
            target: KiwiToken.VaultStoragePath
        )

        let receiverCapability = signer.getCapability<&{FungibleToken.Receiver}>(/private/kiwiTokenReceiver)

        // Create a public capability to the Vault that only exposes
        // the balance field through the Balance interface
        signer.link<&KiwiToken.Vault{FungibleToken.Balance}>(
            KiwiToken.BalancePublicPath,
            target: KiwiToken.VaultStoragePath
        )

        let forwarder <- PrivateReceiverForwarder.createNewForwarder(recipient: receiverCapability)

        signer.save(<-forwarder, to: PrivateReceiverForwarder.PrivateReceiverStoragePath)

        signer.link<&PrivateReceiverForwarder.Forwarder>(
            PrivateReceiverForwarder.PrivateReceiverPublicPath,
            target: PrivateReceiverForwarder.PrivateReceiverStoragePath
        )
    }
}
