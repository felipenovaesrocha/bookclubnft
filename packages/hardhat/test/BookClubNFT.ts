import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
// import lib to create merkler tree root, hash and proof
import { MerkleTree } from "merkletreejs";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { BookClubNFT } from "../typechain-types";
import { keccak256 } from "ethers/lib/utils";

// leave like list random eth address of 40 bytes starting with 0x
const leaves = [
  "0x2F9e113434aeBDd70bB99cB6505e1F726C578D6d",
  "0x3CeeF2C35d55a61514CeCe32C165fB96536d76c4",
  "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
  "0xDd90c56CfD1B60B2d84B8a164c03e57628D7C70A",
  "0x90a3a3F7Cbb46DdA8A06B0Cf49b7cF56f68e1d91",
  "0x9Cf51Dd5b5F5c3dc3bBc54bB78B8d09c0C4Fe6B4",
  "0x7e1746Bfd16D74C68dcD6748b55aE6Df6B165F6c",
  "0x6Bb269f8d7cE70828e238e1fc22d5A5b1c5A5a5f",
  "0xC8f83C67b1ddD6283a3d0DAA12BcF3141f76Fc7C",
  "0x7E92476f01D4720eB86425E544d7C860b2efCf16",
  "0x34B94d39B6B463bF71Ea8d7fE9292fD9641a2399",
  "0xaE205ACa32dc53560eC00dC8B13B6161a3F7F3f2",
].map((leaf) => keccak256(leaf.toLowerCase()));

const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });

function createMerkleTreeRootAndProof(
  address: string = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
) {
  const dataToProve = address.toLowerCase();
  const dataToProveHash = keccak256(dataToProve);
  console.log(`dataToProveHash: ${dataToProveHash}`);

  const proof = tree.getHexProof(dataToProveHash);

  console.log(`Prova de inclusão para o endereço ${dataToProve}:`);
  // console.log(`${JSON.stringify(proof, null, 4)}`);

  const root = tree.getHexRoot();

  const sa = tree.verify(proof, dataToProveHash, root);
  console.log(`Verificação da prova: ${sa}`);

  console.log(`Raiz da árvore: ${root}`);

  return { root, proof };
}

interface BookClubNFTFixture {
  owner: SignerWithAddress;
  otherAccount: SignerWithAddress;
  bookClubNFT: BookClubNFT;
}

interface Proof {
  position: "left" | "right";
  data: Buffer;
}

describe("BookClubNFT", function () {
  let ROOT_MK: string;
  let PROOF: Array<string>;
  let fixture: () => Promise<BookClubNFTFixture>;

  // create merkle tree root and proof
  const { root: _root, proof: _proof } = createMerkleTreeRootAndProof();
  ROOT_MK = _root;
  PROOF = _proof;
  // before each it
  beforeEach(async function () {
    //create Fixture to deploy BookClubNFT contract
    fixture = async function (): Promise<BookClubNFTFixture> {
      const [owner, otherAccount] = await ethers.getSigners();
      const BookClubNFT = await ethers.getContractFactory("BookClubNFT");
      const bookClubNFT = (await upgrades.deployProxy(BookClubNFT, [], {
        initializer: "initialize",
      })) as BookClubNFT;
      // const bookClubNFT = await BookClubNFT.deploy();
      await bookClubNFT.deployed();

      return { owner, otherAccount, bookClubNFT };
    };
  });

  // should set root proof at BookClubNFT contract
  it("should set root proof at BookClubNFT contract", async function () {
    const { owner, otherAccount, bookClubNFT } =
      await loadFixture<BookClubNFTFixture>(fixture);

    const bookID = bookClubNFT.BOOK_NFT_RANGE_START();
    // call setBookMerkleRoot with owner account
    await bookClubNFT.connect(owner).setBookMerkleRoot(bookID, ROOT_MK);

    const merkleRoot = await bookClubNFT.getBookMerkleRoot(bookID);

    expect(merkleRoot).to.equal(ROOT_MK);
  });

  it("should mint claim with proof", async function () {
    const { owner, otherAccount, bookClubNFT } =
      await loadFixture<BookClubNFTFixture>(fixture);

    const bookID = bookClubNFT.BOOK_NFT_RANGE_START();
    // expect with reverted message
    await expect(
      bookClubNFT.mintClaimBookNFT(bookID, PROOF)
    ).to.be.revertedWith(new RegExp("BC:5")); //'[BC:5] BookId dont have root Merkle tree'

    // set root merkle tree
    await bookClubNFT.connect(owner).setBookMerkleRoot(bookID, ROOT_MK);

    await bookClubNFT.mintClaimBookNFT(bookID, PROOF);

    expect(await bookClubNFT.hasClaimedBookNFT(owner.address, bookID)).to.equal(
      true
    );
  });
});
