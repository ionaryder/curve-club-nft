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
    const [owner] = await ethers.getSigners();
    console.log("owner", owner.address)

    expect(await curveNFT.whitelistUsers(['0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266']));
    console.log("Whitelist owner")
    
    expect(await curveNFT.max_supply()).to.equal(100);
    console.log("Test that max supply is 100")

    expect(await curveNFT.onlyWhiteListed()).to.equal(true);
    console.log("Test that only whitelisted users can mint")

    expect(await curveNFT.saleActive(true));
    console.log("Test saleActive value to true")

    expect(await curveNFT.isSaleActive()).to.equal(true);
    console.log("Test isSaleActive value is true")

    expect(await curveNFT.setPrice(0));
    console.log("Setting price to 0 for mint")

    //Q: how do i test without a mint price of 0
    expect(await curveNFT.mint(1));
    console.log("Test mint function: saleActive, whitelistedUser, sufficient funds, can only mint 1 NFT")

    //Not sure if this is working
    // const userMembershipStartTime = await curveNFT.userData[owner.address];
    // console.log("Timestamp member minted", userMembershipStartTime)

    const membershipLength = await curveNFT.howLongMember(); //only one user one mint, so how can i test this better?
    console.log("how long member", membershipLength)

    // Example of a test

    /* const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal("Hola, mundo!"); */
  });
});
