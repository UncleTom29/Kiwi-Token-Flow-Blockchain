
// This transaction is a template for a transaction
// to add a Vault resource to their account
// so that they can use the KiwiToken

import FungibleToken from "./../contracts/FungibleToken.cdc"
import KiwiToken from "./../contracts/KiwiToken.cdc"

transaction {

    prepare(signer: AuthAccount) {

        // Return early if the account already stores a KiwiToken Vault
        if signer.borrow<&KiwiToken.Vault>(from: KiwiToken.VaultStoragePath) != nil {
            return
        }

        // Create a new KiwiToken Vault and put it in storage
        signer.save(
            <-KiwiToken.createEmptyVault(),
            to: KiwiToken.VaultStoragePath
        )

        // Create a public capability to the Vault that only exposes
        // the deposit function through the Receiver interface
        signer.link<&KiwiToken.Vault{FungibleToken.Receiver}>(
            KiwiToken.ReceiverPublicPath,
            target: KiwiToken.VaultStoragePath
        )

        // Create a public capability to the Vault that only exposes
        // the balance field through the Balance interface
        signer.link<&KiwiToken.Vault{FungibleToken.Balance}>(
            KiwiToken.BalancePublicPath,
            target: KiwiToken.VaultStoragePath
        )
    }
}
