// This script reads the balance field of an account's FlowToken Balance

import FungibleToken from 0x01
import FlowToken from 0x02

pub fun main(): UFix64 {

    // Get the public account object of the account
    let account = getAccount(0x02)

    // Retrieve their public Balance reference from their account
    let balanceRef = account
        .getCapability(/public/flowTokenBalance)!
        .borrow<&{FungibleToken.Balance}>()!

    // get the balance of their Vault
    let balance = balanceRef.balance

    log(balance)

    return balance
}