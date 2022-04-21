//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./ERC2981ContractWideRoyalties.sol";

/// @title Flatus-Genesis NFT mitifier

contract FlatusGenesis is
    ERC721URIStorage,
    // ERC721,
    Ownable,
    ERC2981ContractWideRoyalties
{
    //configuration
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    string baseURI;
    string public baseExtension = ".json";
    uint256 nextTokenId;

    constructor() ERC721("FlatusGenesisNFT", "FGNFT") {}

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

    function mintNFT(address recipient, string memory tokenURI)
        public
        onlyOwner
        virtual
        returns (uint256)
    {        
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    function payMe(address recipient) public payable virtual returns (address) {
        require(msg.value >= 20, "Not enough ETH sent; check price!"); // requests payment prior to minting
        payable(owner()).transfer(msg.value);
        return recipient;
    }

    function withdraw() public payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
