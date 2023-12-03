//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./ERC2981ContractWideRoyalties.sol";

/// @title Flatus NFT mitifier

contract Flatus is
    ERC721URIStorage,
    // ERC721,
    Ownable,
    ERC2981ContractWideRoyalties
{
 
   using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    uint256 _tokenId = 1;

    uint256 public mintPrice = 0.08 ether;    
    uint256 public maxPerWallet = 20;
    mapping(address => uint256) public walletMints;

    constructor() ERC721("Flatus", "FART") {}

    //TODO: What is this? I know it has something to do with opensea.
    function contractURI() public pure returns (string memory) {
        return "https://metadata-url.com/my-metadata";
    }

    //TODO: check what other methods are missing
    
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

    //TODO: Set default hardcoded royalties, and change receipient to be owner

    /// @notice Allows to set the royalties on the contract
    /// @dev This function in a real contract should be protected with a onlyOwner (or equivalent) modifier
    /// @param recipient the royalties recipient
    /// @param value percentage (using 2 decimals - 10000 = 100, 0 = 0)
    function setRoyalties(address recipient, uint256 value) public onlyOwner {
        _setRoyalties(recipient, value);
    }

    //todo: change mintToken to accept only buyer address and amount, token should link to metadata - baseURI+TokenId

    function mintToken(address recipient, string[] memory uri) public payable {
        require((uri.length) * mintPrice == msg.value, "wrong amount sent");
        require(walletMints[msg.sender] + (uri.length) <= maxPerWallet, "mints per wallet exceeded");
        walletMints[msg.sender] += (uri.length);
        for (uint8 i = 0; i<uri.length; i++){
            _tokenId = _tokenIdCounter.current();      
            _tokenIdCounter.increment();
            _safeMint(recipient, _tokenId);
            _setTokenURI(_tokenId, uri[i]);
        }
    }

    function getWalletMints(address wallet) public onlyOwner view returns (uint256) {
        return walletMints[wallet];
    }

    function setMaxPerWallet(uint256 max) public onlyOwner  {
        maxPerWallet = max;
    }

    function setMintPrice(uint256 price) public onlyOwner {
        mintPrice = price;
    }

}
