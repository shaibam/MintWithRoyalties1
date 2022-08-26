// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol"; // ERC2981 NFT Royalty Standard

contract Flatus is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable, ERC2981 {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    bool private revealed = false;
    string private preReavelURL = "https://gateway.pinata.cloud/ipfs/QmW5haM17kF96Xnh1uiDtjUXjaKjjy6VPYV4mArgJERSbT"; //fourth template

    uint256 public mintPrice = 0.01 ether;    
    uint256 public maxPerWallet = 20;
    mapping(address => uint256) public walletMints;    

    constructor() ERC721("Flatus", "FART") {
        _setDefaultRoyalty(owner(),450); //100 = 1% 
    }    

    function mintToken(address recipient, string[] memory uri) public payable {
        require((uri.length) * mintPrice == msg.value, "wrong amount sent ");
        require(walletMints[msg.sender] + (uri.length) <= maxPerWallet, "mints per wallet exceeded");
        walletMints[msg.sender] += (uri.length);
        for (uint8 i = 0; i<uri.length; i++){
            uint256 _tokenId = _tokenIdCounter.current();      
            _tokenIdCounter.increment();
            _safeMint(recipient, _tokenId);
            _setTokenURI(_tokenId, uri[i]);
        }
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        if (revealed == true) {
            return super.tokenURI(tokenId);                
        } else {           
            return preReavelURL;
        }
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function revealCollection() public onlyOwner  {
        revealed = true;
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
    
    function setRoyaltyPercent(uint96 feeNumerator) public onlyOwner {
        _setDefaultRoyalty(owner(),feeNumerator); //100 = 1% 
    }

    function getContractOwner() public view returns (address){
        return owner();
    }   

}
