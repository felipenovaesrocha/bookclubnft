import { ethers, upgrades } from "hardhat";

async function main() {
  const [owner] = await ethers.getSigners(); // Obter o primeiro Signer retornado por getSigners()

  const bookClub = await ethers.getContractFactory("BookClubNFT");
  const bookNFT = await upgrades.deployProxy(bookClub, [], {
    initializer: "initialize",
  });

  await bookNFT.deployed();

  console.log(
    `BookNFT deployed at ${bookNFT.address} with owner ${owner.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
