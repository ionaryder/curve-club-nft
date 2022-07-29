//SPDX-License-Identifier: MIT

pragma solidity >=0.8.1;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CurveFoundv1 is ERC721URIStorage, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    bool public isSaleActive = false;
    address[] public whitelistedAddresses;
    bool public onlyWhiteListed = true;
    uint256 public constant max_supply = 100;
    uint256 public constant max_curve_mint = 1;
    string public notRevealedUri;
    uint256 public price = 3 ether;
    uint256 private _reserved = 0;

    uint256 public tokenId = 0;
    mapping(address => uint256) public addressPresaleMinted; // ensures user cannot purchase, transfer and then purchase another
    mapping(address => uint256) userData; // the date a user minted their NFT + 10 years (tracks time to expired)

    event CurveNFTMinted(address indexed sender, uint256 tokenId);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initNotRevealedUri
    ) ERC721(_name, _symbol) {
        setNotRevealedURI(_initNotRevealedUri);
        _tokenIds.increment();
    }

    function mint(uint256 _mintAmount) external payable {
        require(isSaleActive == true, "Hold up! The sale is not active yet");
        require(isWhitelisted(msg.sender), "user is not whitelisted");
        require(_mintAmount > 0, "You can't buy 0 memberships");
        require(
            _mintAmount <= max_curve_mint,
            "max mint amount per session exceeded"
        );
        require(
            (_tokenIds.current() + _mintAmount) <= max_supply - _reserved,
            "max NFT limit exceeded"
        );
        require(msg.value >= price * _mintAmount, "insufficient funds");
        userData[msg.sender] = block.timestamp + 10 * 365 days;
        uint256 newTokenId = _tokenIds.current();
        _safeMint(msg.sender, newTokenId);
        // setTokenURI();  --> set the tokenURI of the tokenId just minted
        emit CurveNFTMinted(msg.sender, tokenId);
    }

    //START MEMBERSHIP CODE

    modifier hasExpired() {
        // hasExpired modifier runs before any function called to make sure conditions are met.
        require(
            userData[msg.sender] < block.timestamp,
            "Your membership has expired"
        ); // This will check to see if it's expired. block.timestamp is now.
        _;
    }

    /* function performMembersAction() public hasExpired  {
        //burn token here
        _burn(tokenId);
    } */

    // member can update their membership by 10 years from now
    function updateMembership() public {
        userData[msg.sender] = block.timestamp + 10 * 365 days; // 10 year membership
    }

    function deleteMembership() public {
        userData[msg.sender] = 0;
    }

    function isMember() public view returns (bool) {
        if (userData[msg.sender] > 0) {
            return true;
        } else {
            return false;
        }
    }

    function howLongMember() public view returns (uint256) {
        if (userData[msg.sender] > 0)
            return (userData[msg.sender] - block.timestamp);
        else return (0);
    }

    //END MEMBERSHIP CODE

    //START RESERVE FUNCTIONS

    function reserve(uint256 n) public onlyOwner {
        _safeMint(msg.sender, n);
        // right now you are not setting the tokenURI
    }

    function getReservedLeft() public view returns (uint256) {
        return _reserved;
    }

    function claimReserved(uint256 _number, address _receiver)
        external
        onlyOwner
    {
        require(_number <= _reserved, "That would exceed the max reserved.");

        _safeMint(_receiver, _number);

        _reserved = _reserved - _number;
    }

    //END RESERVE FUNCTIONS

    // START WHITELIST FUNCTIONS

    function setOnlyWhitelisted(bool _state) public onlyOwner {
        onlyWhiteListed = _state;
    }

    // are you storing an array/ list of these addresses somewhere manually?
    function whitelistUsers(address[] calldata _users) public onlyOwner {
        delete whitelistedAddresses;
        whitelistedAddresses = _users;
    }

    // returns if address is whitelisted or not
    function isWhitelisted(address _user) public view returns (bool) {
        for (uint256 i = 0; i < whitelistedAddresses.length; i++) {
            if (whitelistedAddresses[i] == _user) {
                return true;
            }
        }
        return false;
    }

    //END WHITELIST FUNCTIONS

    // toggle sale active state
    function saleActive(bool change) public onlyOwner {
        isSaleActive = change;
    }

    // set nft price
    function setPrice(uint256 _newPrice) external onlyOwner {
        price = _newPrice;
    }

    function withdraw() public payable onlyOwner nonReentrant {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }

    // only contract owner can burn member token
    function burn(uint256 _tokenId) public onlyOwner {
        _burn(_tokenId);
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }
}
