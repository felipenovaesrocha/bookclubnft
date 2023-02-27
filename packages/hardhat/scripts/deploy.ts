import { ethers, upgrades } from "hardhat";
async function main() {
  const bookClub = await ethers.getContractFactory("BookClubNFT");
  const bookNFT = await upgrades.deployProxy(bookClub);

  await bookNFT.deployed();

  console.log(`BookNFT deployed at ${bookNFT.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
