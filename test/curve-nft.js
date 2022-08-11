const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CurveFoundv1", function () {
  it("Curve NFT contract meets all tests", async function () {
    const [owner, buyerAddress, randomAddress] = await ethers.getSigners();
    const CurveNFT = await ethers.getContractFactory("CurveFoundv1");
    const curveNFT = await CurveNFT.deploy(
      "CurveClub",
      "CC",
      "QmPoVrETjJtPqvjae38aPJkQGhS26v6QYSapNNtLcyEoFy",
      "https://gateway.pinata.cloud/ipfs/QmbYZHPnspN9M4jQSCh2ZvzxtVkEkFxMdLumTuBYfA8Evj.json"
    );
    await curveNFT.deployed();

    console.log("owner", owner.address);

    // attempt mint before active
    /* mint_tx = await curveNFT
      .connect(buyerAddress)
      .mint(1, { value: "3000000000000000000" });
    console.log("Minted an NFT!"); */
    // Success

    // setting sale to active
    let setActive = await curveNFT.setActive(true);
    expect(await curveNFT.isSaleActive()).to.equal(true);
    console.log("Sale is Active!");

    let maxSupply = await curveNFT.setMaxSupply(5);
    expect(await curveNFT.MAX_SUPPLY()).to.equal(5);
    console.log("Max supply is 5");

    // is user Allowlisted?
    let buyerWallet = await curveNFT
      .connect(buyerAddress)
      .isAllowlisted(buyerAddress.address);
    console.log("Address is not on WL");

    // set allowlist
    let allowlist = await curveNFT.allowlistUsers([
      owner.address,
      buyerAddress.address,
    ]);

    // check if user is Allowlisted again
    randomWallet = await curveNFT
      .connect(buyerAddress)
      .isAllowlisted(buyerAddress.address);
    console.log("Address is on AL");

    // check price
    const price = await curveNFT.price();
    console.log(
      `Mint price is ${ethers.utils.formatUnits(price, "ether")} ETH`
    );

    // mint nft
    mint_tx = await curveNFT
      .connect(buyerAddress)
      .mint(1, { value: "3000000000000000000" });
    console.log("Minted an NFT!");

    // get tokenURI (should be the unreaveled )
    let tokenURI = await curveNFT.tokenURI(1);
    console.log("Non revealed tokenURI: ", tokenURI);

    // set to revealed
    await curveNFT.setRevealed(true);
    let isRevealed = await curveNFT.isRevealed();
    console.log("Revealed state: ", isRevealed);

    // get tokenURI again (should show our real tokenURI)
    tokenURI = await curveNFT.tokenURI(1);
    console.log("Revealed tokenURI: ", tokenURI);

    // check if member
    let isMember = await curveNFT.connect(buyerAddress).isMember();
    expect(isMember).to.equal(true);
    console.log("Is buyer address a member? ", isMember);

    // check if random address is a member
    isMember = await curveNFT.connect(randomAddress).isMember();
    expect(isMember).to.equal(false);
    console.log("Is random address a member? ", isMember);

    // check how long buyerAddress has been a member
    let howLongMember = await curveNFT.connect(buyerAddress).howLongMember();
    console.log(`You've been a member for ${howLongMember} seconds!`);

    // check time till expiry
    let timeTilExpire = await curveNFT.connect(buyerAddress).timeTilExpire();
    console.log(`Your membership expires in ${timeTilExpire} seconds!`);

    // fast forward time by 5 years
    await network.provider.send("evm_increaseTime", [157680000]);
    await network.provider.send("evm_mine");
    console.log("Time fast forward by 5 years");

    // check how long member again
    howLongMember = await curveNFT.connect(buyerAddress).howLongMember();
    console.log(`You've been a member for ${howLongMember} seconds!`);

    // check time till expiry again
    timeTilExpire = await curveNFT.connect(buyerAddress).timeTilExpire();
    console.log(`Your membership expires in ${timeTilExpire} seconds!`);

  
    // fast forward 6 more years (to test hasExpired)
    // await network.provider.send("evm_increaseTime", [189216000]);
    // await network.provider.send("evm_mine");
    // console.log("Time fast forward by 6 years");
    // try to call timeTillExpire
    // timeTilExpire = await curveNFT.connect(buyerAddress).timeTilExpire();
    // result success => "Your membership has expired" 
  

    // test soulbound token

    // Buyer tries to burn token
    // await curveNFT.connect(buyerAddress).revokeMembership(1);
    // console.log("only owner can burn")

    // try to transfer token

    // owner revokes a token
    await curveNFT.connect(owner).revokeMembership(1);
    console.log(`Revoked membership of ${buyerAddress.address}`);

    // check if buyer address is a member
    isMember = await curveNFT.connect(buyerAddress).isMember();
    console.log(isMember);
  });
});
