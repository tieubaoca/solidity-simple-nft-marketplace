// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleNFTMarketplace is Ownable {
    struct ListingToken {
        uint256 tokenId;
        address owner;
        uint256 price;
    }
    address public simpleToken;
    address public simpleNFT;
    uint256 public totalAmounttokens;
    mapping(address => mapping(uint256 => uint256)) tokensByOwner;
    mapping(address => uint256) listingTokensAmountByOwner;
    mapping(uint256 => uint256) tokenIndexById;
    mapping(uint256 => ListingToken) public listingTokens; //id => nft

    constructor(address _simpleToken, address _simpleNFT) Ownable() {
        simpleToken = _simpleToken;
        simpleNFT = _simpleNFT;
    }

    function list(uint256 _tokenId, uint256 _price) public {
        require(_price > 0, "Price must be greater than 0");
        IERC721(simpleNFT).transferFrom(msg.sender, address(this), _tokenId);
        tokensByOwner[msg.sender][
            listingTokensAmountByOwner[msg.sender]
        ] = _tokenId;
        listingTokens[_tokenId] = ListingToken(_tokenId, msg.sender, _price);
        tokenIndexById[_tokenId] = listingTokensAmountByOwner[msg.sender];
        listingTokensAmountByOwner[msg.sender] += 1;
        totalAmounttokens += 1;
    }

    function delist(uint256 _tokenId) public {
        require(
            listingTokens[_tokenId].owner == msg.sender,
            "You do not own this token"
        );
        IERC721(simpleNFT).transferFrom(address(this), msg.sender, _tokenId);
        _delist(_tokenId);
    }

    function purchase(uint256 _tokenId) public {
        require(
            listingTokens[_tokenId].price > 0,
            "NFT has not been listed yet!"
        );
        IERC20(simpleToken).transferFrom(
            msg.sender,
            listingTokens[_tokenId].owner,
            listingTokens[_tokenId].price
        );
        IERC721Enumerable(simpleNFT).transferFrom(
            address(this),
            msg.sender,
            _tokenId
        );
        _delist(_tokenId);
    }

    function _delist(uint256 _tokenId) internal {
        address owner = listingTokens[_tokenId].owner;
        uint256 lastTokenIndex = listingTokensAmountByOwner[owner] - 1;
        if (tokensByOwner[owner][lastTokenIndex] != _tokenId) {
            uint256 tokenIndex = tokenIndexById[_tokenId];
            tokensByOwner[owner][tokenIndex] = tokensByOwner[owner][
                lastTokenIndex
            ];
            tokenIndexById[tokensByOwner[owner][lastTokenIndex]] = tokenIndex;
        }
        delete listingTokens[_tokenId];
        delete tokensByOwner[owner][lastTokenIndex];
        delete tokenIndexById[_tokenId];
        totalAmounttokens -= 1;
        listingTokensAmountByOwner[owner] -= 1;
    }
}
