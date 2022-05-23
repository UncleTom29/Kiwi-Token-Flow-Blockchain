import path from "path";
import { emulator, init, getAccountAddress, deployContractByName, sendTransaction, shallPass, 
  executeScript, shallRevert, getFlowBalance, mintFlow } from "flow-js-testing";
import fs from "fs";

//const zzz = fs.readFileSync(path.resolve(__dirname, "../mockTransactions/zzz.cdc"), {encoding:'utf8', flag:'r'});

// Increase timeout if your tests failing due to timeout
jest.setTimeout(10000);

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function deployContract(param) {
  const [result, error] = await deployContractByName(param);
  if (error != null) {
    console.log(`Error in deployment - ${error}`);
    emulator.stop();
    process.exit(1);
  }
}

async function getCurrentTimestamp() {
  const code = `
    pub fun main(): UInt64 {
      return UInt64(getCurrentBlock().timestamp)
    }
  `;
  return await executeScript({ code });
}


describe("exampletoken", ()=>{

  let fungibleTokenContractAddress;
  let exampleTokenContractAddress;
  let exampleTokenAdmin;
  let exampleTokenUser;

  beforeEach(async () => {
    const basePath = path.resolve(__dirname, "../../"); 
		// You can specify different port to parallelize execution of describe blocks
    const port = 8080; 
		// Setting logging flag to true will pipe emulator output to console
    const logging = false;

    await init(basePath, { port });
    await emulator.start(port, {logging});

    // Deployed at address which has the alias - fungibleToken
    fungibleTokenContractAddress = await getAccountAddress("fungibleToken");
    // Deployed at address which has the alias - exampleToken
    exampleTokenContractAddress = await getAccountAddress("exampleToken");


    await deployContract({ to: fungibleTokenContractAddress,    name: "FungibleToken"});
    await deployContract({ to: exampleTokenContractAddress,       name: "ExampleToken"});

    exampleTokenAdmin = await getAccountAddress("exampleTokenAdmin");
    exampleTokenUser  = await getAccountAddress("exampleTokenUser");
  
  });

  // Stop emulator, so it could be restarted
  afterEach(async () => {
    return emulator.stop();
  });
  
  test("should be able to create an empty vault and create capabilities", async () => {
    await shallPass(
      sendTransaction({
        name: "setup_account",
        args: [],
        signers: [exampleTokenUser]
      })
    );
  })
})