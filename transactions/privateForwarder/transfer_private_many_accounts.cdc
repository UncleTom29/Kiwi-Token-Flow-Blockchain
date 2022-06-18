import FungibleToken from "../../contracts/FungibleToken.cdc"
import KiwiToken from "../../contracts/KiwiToken.cdc"
import PrivateReceiverForwarder from "../../contracts/PrivateReceiverForwarder.cdc"

/// This transaction transfers to many addresses through their private receivers

transaction(addressAmountMap: {Address: UFix64}) {

    // The Vault resource that holds the tokens that are being transferred
    let vaultRef: &KiwiToken.Vault

    let privateForwardingSender: &PrivateReceiverForwarder.Sender

    prepare(signer: AuthAccount) {

        // Get a reference to the signer's stored vault
        self.vaultRef = signer.borrow<&KiwiToken.Vault>(from: KiwiToken.VaultStoragePath)
			?? panic("Could not borrow reference to the owner's Vault!")

        self.privateForwardingSender = signer.borrow<&PrivateReceiverForwarder.Sender>(from: PrivateReceiverForwarder.SenderStoragePath)
			?? panic("Could not borrow reference to the owner's Vault!")

    }

    execute {

        for address in addressAmountMap.keys {

            self.privateForwardingSender.sendPrivateTokens(address, tokens: <-self.vaultRef.withdraw(amount: addressAmountMap[address]!))

        }
    }
}
