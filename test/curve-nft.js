const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CurveNFT", function () {
  it("", async function () {
    const CurveNFT = await ethers.getContractFactory("CurveFoundv1");
    const curveNFT = await CurveNFT.deploy(
      "CurveClub",
      "CC",
      "https://ipfs.io/ipfs/QmeAnbyCYZo6MiDhuQSn6imX5GSjJ62v6SZU6VuiJrP6J9/hidden_ghost.png"
    );
    await curveNFT.deployed();

    expect(await curveNFT.max_supply()).to.equal(100);

    // Example of a test

    /* const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal("Hola, mundo!"); */
  });
});
