const hre = require("hardhat");

async function main() {
  const [owner, buyerAddress1] = await hre.ethers.getSigners();
  const CurveFoundv1 = await hre.ethers.getContractFactory("CurveFoundv1");
  const curveFoundv1 = await CurveFoundv1.deploy(
    "CurveClub",
    "CC",
    "QmPoVrETjJtPqvjae38aPJkQGhS26v6QYSapNNtLcyEoFy",
    "ipfs://QmZQph5Wv8mvzcQGnHgcPFzkfLAF7vADsnJ4nbuN8yfXRT"
  );
  await curveFoundv1.deployed();
  console.log("Contract deployed at: ", curveFoundv1.address);
  console.log("Contract Owner: ", owner.address);

  // set sale state to active
  // let tx = await curveFoundv1.saleActive(true);

  // // mint nft
  // let mint_tx = await curveFoundv1.mint(1, { value: "3000000000000000000" });
  // await mint_tx.wait();
  // console.log("NFT #1 Minted!");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
