// This script reads the total supply field
// of the KiwiToken smart contract

import KiwiToken from "../../contracts/KiwiTokenn.cdc"

pub fun main(): UFix64 {

    let supply = KiwiToken.totalSupply

    log(supply)

    return supply
}
