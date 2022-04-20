//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./ERC2981ContractWideRoyalties.sol";

/// @title Flatus-Genesis NFT mitifier

contract FlatusGenesis is
    ERC721URIStorage,
    Pausable,
    ReentrancyGuard,
    Ownable,
    ERC2981ContractWideRoyalties
{
    //configuration
    // Address of OZ Defender's Relayer
    address private immutable _defender;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    string baseURI;
    string public baseExtension = ".json";
    uint256 nextTokenId;

    constructor(address defender) ERC721("FlatusGenesisNFT", "FGNFT") {
        require(defender != address(0));
        _defender = defender;
    }

    /// @inheritdoc	ERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC2981Base)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /// @notice Allows to set the royalties on the contract
    /// @dev This function in a real contract should be protected with a onlyOwner (or equivalent) modifier
    /// @param recipient the royalties recipient
    /// @param value percentage (using 2 decimals - 10000 = 100, 0 = 0)
    function setRoyalties(address recipient, uint256 value) public onlyOwner {
        _setRoyalties(recipient, value);
    }

    function mintNFT(
        address recipient,
        string memory tokenURI,
        bytes32 hash,
        bytes memory signature
    ) public payable virtual returns (uint256) {
        uint256 tokenId = _tokenIds.current();

        require(
            hash == keccak256(abi.encode(msg.sender, tokenId, address(this))),
            "Invalid hash"
        );

        require(
            ECDSA.recover(ECDSA.toEthSignedMessageHash(hash), signature) ==
                _defender,
            "Invalid signature"
        );

        require(msg.value >= 20, "Not enough ETH sent; check price!"); // requests payment prior to minting

        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    function pause() external {
        require(msg.sender == _defender, "Unauthorized");
        _pause();
    }

    function unpause() external {
        require(msg.sender == _defender, "Unauthorized");
        _unpause();
    }
}
