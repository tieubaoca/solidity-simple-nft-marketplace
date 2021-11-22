// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract SimpleNFT is ERC721Enumerable {
    address public paymentToken;
    address mintfeeReceiver;
    uint256 public constant MINT_FEE = 10**18;
    uint256 count;
    mapping(uint256 => string) _tokenURI;

    constructor(address _paymentToken, address _mintfeeReceiver)
        ERC721("My Simple NFT", "SNFT")
    {
        paymentToken = _paymentToken;
        mintfeeReceiver = _mintfeeReceiver;
    }

    function mint(string calldata __tokenURI) public {
        IERC20(paymentToken).transferFrom(
            msg.sender,
            mintfeeReceiver,
            MINT_FEE
        );
        _tokenURI[count] = __tokenURI;
        _mint(msg.sender, count);
        count++;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        return _tokenURI[_tokenId];
    }
}
