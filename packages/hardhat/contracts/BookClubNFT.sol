// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/**
 * @dev This is an ERC1155 implementation of BookClubNFT contract.
 * It allows the creation and issuance of two types of NFTs:
 * - Exclusive Bankless NFT: A unique NFT that anyone can mint for themselves
 * - Book NFTs: Multiple NFTs that represent different books that can only be claimed by the specific addresses added to the Merkle tree for that book.
 *
 * Only the contract owner can mint Book NFTs and update the Merkle root for each book.
 * Once a user's address has been added to the Merkle tree for a specific book, they can claim the corresponding NFT for that book.
 *
 * A maximum of one Exclusive Bankless NFT can be minted per address.
 */
contract BookClubNFT is
    Initializable,
    ERC1155Upgradeable,
    ERC1155URIStorageUpgradeable,
    UUPSUpgradeable,
    OwnableUpgradeable
{
    // Constants for token types
    uint256 public constant BANKLESS_EXCLUSIVE_NFT = 1;
    uint256 public constant BOOK_NFT_RANGE_START = 2;
    uint256 public constant BOOK_NFT_RANGE_END = 6;

    // Mapping to keep track of claimed Book NFTs
    mapping(address => mapping(uint256 => bool)) private _claimedBookNFTs;

    // Mapping of Merkle roots for each book ID
    mapping(uint256 => bytes32) private _bookMerkleRoots;

    // Event emitted when an Exclusive Bankless NFT is minted
    event ExclusiveNFTMinted(address indexed to, uint256 indexed tokenId);

    // Event emitted when a Book NFT is minted1
    event BookNFTMinted(address indexed to, uint256 indexed tokenId);

    /**
     * @dev Initialize the ERC1155 contract and set it up with URI storage and Ownable features.
     */
    function initialize() public initializer {
        __ERC1155_init("");
        __ERC1155URIStorage_init();
        __Ownable_init();
    }

    /**
     * @notice Sets the URI for a given token ID
     * @dev Overrides the default implementation in ERC1155URIStorageUpgradeable
     * @param tokenId uint256 ID of the token to set the URI for
     * @param tokenURI string URI to set for the token
     */
    function setURI(
        uint256 tokenId,
        string memory tokenURI
    ) public virtual onlyOwner {
        _setURI(tokenId, tokenURI);
    }

    /**
     * @notice Mints the exclusive Bankless NFT for the contract owner
     * @dev The exclusive NFT is a one-time use token that can only be minted once per address
     * @param to address Recipient of the exclusive NFT
     */
    function mintExclusiveNFT_owner(address to) external virtual onlyOwner {
        _mintExclusiveNFT(to);
    }

    /**
     * @notice Internal function to mint an Exclusive Bankless NFT for a specific address
     * @dev The exclusive NFT is a one-time use token that can only be minted once per address
     */
    function _mintExclusiveNFT(address to) internal virtual {
        require(
            balanceOf(to, BANKLESS_EXCLUSIVE_NFT) == 0,
            "[BC:1] Only 1 exclusive NFT per address"
        );
        _mint(to, BANKLESS_EXCLUSIVE_NFT, 1, "");
        emit ExclusiveNFTMinted(to, BANKLESS_EXCLUSIVE_NFT);
    }

    /**
     * @notice Mints the exclusive Bankless NFT for the caller
     * @dev The exclusive NFT is a one-time use token that can only be minted once per address
     */
    function mintBanklessExclusiveNFT() external virtual {
        _mintExclusiveNFT(msg.sender);
    }

    /**
     * @notice Mints a Book NFT for the specified recipient
     * @param to address Recipient of the Book NFT
     * @param bookId uint256 ID of the Book NFT to mint
     */
    function mintBookNFTDirect(
        address to,
        uint256 bookId
    ) public virtual onlyOwner {
        require(
            bookId >= BOOK_NFT_RANGE_START && bookId <= BOOK_NFT_RANGE_END,
            "[BC:2] Invalid book ID"
        );
        _mint(to, bookId, 1, "");
        emit BookNFTMinted(to, bookId);
    }

    function uri(
        uint256 tokenId
    )
        public
        view
        virtual
        override(ERC1155URIStorageUpgradeable, ERC1155Upgradeable)
        returns (string memory)
    {
        return ERC1155URIStorageUpgradeable.uri(tokenId);
    }

    /**
     * @notice Mints a Book NFT for the caller if they are in the merkle tree for the book
     * @dev The Book NFT can only be minted once per address, and the caller must be in the merkle tree for the book
     * @param bookId uint256 ID of the Book NFT to mint
     * @param proof bytes32[] Proof of inclusion in the merkle tree
     */
    function mintClaimBookNFT(
        uint256 bookId,
        bytes32[] calldata proof
    ) external virtual {
        _internalMintBookNFT(msg.sender, bookId, proof);
    }

    /**
     * @dev Internal function to mint a book NFT to the given address if they have claimed it with a valid Merkle proof.
     * If the claim is valid, the NFT is minted and marked as claimed for that address.
     * @param to The address to mint the book NFT for.
     * @param bookId The ID of the book NFT to mint.
     * @param proof The Merkle proof of the address claiming the NFT.
     */
    function _internalMintBookNFT(
        address to,
        uint256 bookId,
        bytes32[] calldata proof
    ) internal virtual {
        require(
            bookId >= BOOK_NFT_RANGE_START && bookId <= BOOK_NFT_RANGE_END,
            "[BC:2] Invalid book ID"
        );

        require(
            _bookMerkleRoots[bookId] != bytes32(0x0),
            "[BC:5] BookId dont have root Merkle tree"
        );

        bytes32 merkleRoot = _bookMerkleRoots[bookId];

        require(
            !_claimedBookNFTs[to][bookId],
            "[BC:3] Already claimed BookID NFT for this address"
        );

        require(
            MerkleProofUpgradeable.verifyCalldata(
                proof,
                merkleRoot,
                keccak256(abi.encodePacked(to))
            ),
            "[BC:4] Invalid Merkle proof"
        );

        _mint(to, bookId, 1, "");

        _claimedBookNFTs[to][bookId] = true;

        emit BookNFTMinted(to, bookId);
    }

    /**
     * @notice Sets the merkle root for a given Book NFT
     * @dev The merkle root is used to verify whether an address is included in the merkle tree for a given Book NFT
     * @param bookId uint256 ID of the Book NFT to set the merkle root for
     * @param merkleRoot bytes32 Merkle root to set for the Book NFT
     */
    function setBookMerkleRoot(
        uint256 bookId,
        bytes32 merkleRoot
    ) public virtual onlyOwner {
        require(
            bookId >= BOOK_NFT_RANGE_START && bookId <= BOOK_NFT_RANGE_END,
            "[BC:2] Invalid book ID"
        );

        _bookMerkleRoots[bookId] = merkleRoot;
    }

    /**
     * @dev Gets the Merkle root for the specified book ID.
     * @param bookId The ID of the book to get the Merkle root for.
     * @return The Merkle root for the specified book ID.
     */
    function getBookMerkleRoot(
        uint256 bookId
    ) public view virtual returns (bytes32) {
        require(
            bookId >= BOOK_NFT_RANGE_START && bookId <= BOOK_NFT_RANGE_END,
            "[BC:2] Invalid book ID"
        );

        return _bookMerkleRoots[bookId];
    }

    /**
     * @dev Sets the claimed status of the specified book NFT for the given address.
     * @param to The address to set the claimed status for.
     * @param bookId The ID of the book NFT to set the claimed status for.
     * @param value The new claimed status of the book NFT for the given address.
     */
    function setClaimedBookNFTs(
        address to,
        uint256 bookId,
        bool value
    ) public virtual onlyOwner {
        require(
            bookId >= BOOK_NFT_RANGE_START && bookId <= BOOK_NFT_RANGE_END,
            "[BC:2] Invalid book ID"
        );

        _claimedBookNFTs[to][bookId] = value;
    }

    /**
     * @dev Checks if the specified address has claimed the specified book NFT.
     * @param to The address to check the claimed status for.
     * @param bookId The ID of the book NFT to check the claimed status for.
     * @return A boolean indicating if the specified address has claimed the specified book NFT.
     */
    function hasClaimedBookNFT(
        address to,
        uint256 bookId
    ) public view virtual returns (bool) {
        require(
            bookId >= BOOK_NFT_RANGE_START && bookId <= BOOK_NFT_RANGE_END,
            "[BC:2] Invalid book ID"
        );

        return _claimedBookNFTs[to][bookId];
    }

    function _authorizeUpgrade(address) internal virtual override onlyOwner {}
}
