// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.33;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract FirstCollection721 is ERC721, Ownable {
    uint256 private _nextTokenId;
    uint256 private _priceInWei;
    uint256 private _maxSupply;

    error MaxSupplyReached();
    error UserAlreadyHaveNFT();
    error NotEnougthFounds();
    error NothingToWithdraw();
    error WithdrawFailed();

    constructor(address initialOwner, uint256 _price, uint256 _supply)
        ERC721("FirstCollection721", "SD")
        Ownable(initialOwner)
    {
        _priceInWei = _price;
        _maxSupply = _supply;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmPMc4tcBsMqLRuCQtPmPe84bpSjrC3Ky7t3JWuHXYB4aS/";
    }

    function safeMint(address to) public onlyOwner {
        require(_nextTokenId < _maxSupply, MaxSupplyReached());
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function buy() public payable {
        require(_nextTokenId < _maxSupply, MaxSupplyReached());
        require(msg.value >= _priceInWei, NotEnougthFounds());
        require(super.balanceOf(msg.sender) == 0, UserAlreadyHaveNFT());
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, NothingToWithdraw());

        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, WithdrawFailed());
    }
}
