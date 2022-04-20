const { RELAYER_ADDRESS } = process.env;
async function main() {
  // Grab the contract factory 
  const MyNFT = await ethers.getContractFactory("FlatusGenesis");

  // Start deployment, returning a promise that resolves to a contract object
  const myNFT = await MyNFT.deploy(RELAYER_ADDRESS); // Instance of the contract 
  console.log("Contract deployed to address:", myNFT.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });