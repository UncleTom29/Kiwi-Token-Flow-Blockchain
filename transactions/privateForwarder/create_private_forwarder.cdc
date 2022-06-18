import FungibleToken from "../../contracts/FungibleToken.cdc"
import KiwiToken from "../../contracts/KiwiToken.cdc"
import PrivateReceiverForwarder from "../../contracts/PrivateReceiverForwarder.cdc"

// This transaction creates a new private receiver in an account that 
// doesn't already have a private receiver or a public token receiver
// but does already have a Vault

transaction {

    prepare(signer: AuthAccount) {
        receiverCapability = signer.link<&KiwiToken.Vault{FungibleToken.Receiver}>(
            /private/kiwiTokenReceiver,
            target: KiwiToken.VaultStoragePath
        )

        let vault <- PrivateReceiverForwarder.createNewForwarder(recipient: receiverCapability)

        signer.save(<-vault, to: PrivateReceiverForwarder.PrivateReceiverStoragePath)

        signer.link<&{PrivateReceiverForwarder.Forwarder}>(
            PrivateReceiverForwarder.PrivateReceiverPublicPath,
            target: PrivateReceiverForwarder.PrivateReceiverStoragePath
        )
    }
}
