//SPDX-License-Identifier: MIT

pragma solidity >=0.8.1;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CurveFoundv1 is ERC721URIStorage, Ownable, ReentrancyGuard {
    using Strings for uint256;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    bool public isSaleActive = false;
    bool public isRevealed = false;

    bool public onlyWhiteListed = true;
    address[] public whitelistedAddresses;

    uint256 public constant MAX_SUPPLY = 100;
    uint256 public constant MAX_CURVE_MINT = 1;
    uint256 public price = 3 ether;

    string public notRevealedUri;
    string private cid;

    mapping(address => bool) public hasMinted; // ensures user cannot purchase, transfer and then purchase another
    mapping(address => uint256) public dateMinted; // the time a user minted their NFT

    event CurveNFTMinted(address indexed sender, uint256 tokenId);
    event Attest(address indexed to, uint256 indexed tokenId);
    event Revoke(address indexed to, uint256 indexed tokenId);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _cid,
        string memory _initNotRevealedUri
    ) ERC721(_name, _symbol) {
        cid = _cid;
        _tokenIds.increment();
        setNotRevealedURI(_initNotRevealedUri);
    }

    function mint(uint256 _mintAmount) external payable {
        require(isSaleActive == true, "Hold up! The sale is not active yet");
        require(isWhitelisted(msg.sender), "User is not whitelisted");
        require(_mintAmount > 0, "You can't buy 0 memberships");
        require(
            _mintAmount <= MAX_CURVE_MINT,
            "max mint amount exceeded"
        );
        require(
            (_tokenIds.current() + _mintAmount) <= MAX_SUPPLY,
            "max NFT limit exceeded"
        );
        require(
            hasMinted[msg.sender] == false,
            "You've already minted a membership!"
        );
        require(msg.value >= price * _mintAmount, "insufficient funds");
        hasMinted[msg.sender] = true;
        dateMinted[msg.sender] = block.timestamp;
        uint256 newTokenId = _tokenIds.current();
        _tokenIds.increment();
        _safeMint(msg.sender, newTokenId);

        emit CurveNFTMinted(msg.sender, newTokenId);
    }

    //Overridden transfer function
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override virtual {
        require(from == address(0), "You cannot transfer this token");
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override virtual {
        if (from == address(0)){
            emit Attest(to, tokenId);
        } else if (to == address(0)){
            emit Revoke(to, tokenId);
        }
    }

    //only owner of collection can burn the token 
    function burn(uint256 _tokenId) public onlyOwner {
        _burn(_tokenId);
    }

    //START MEMBERSHIP CODE

    modifier hasExpired() {
        // hasExpired modifier runs before any function called to make sure conditions are met.
        require(
            (dateMinted[msg.sender] + 10 * 365 * 24 * 60 * 60) > block.timestamp,
            "Your membership has expired"
        );
        _;
    }

    function isMember() public view returns (bool) {
        if (dateMinted[msg.sender] > 0) {
            return true;
        } else {
            return false;
        }
    }

    function howLongMember() public view returns (uint256) {
        if (dateMinted[msg.sender] > 0)
            return (block.timestamp - dateMinted[msg.sender]);
        else return (0);
    }

    function timeTilExpire() public view hasExpired returns (uint256 timeLeft) {
        if (dateMinted[msg.sender] > 0) {
            timeLeft =
                (dateMinted[msg.sender] + 10 * 365 * 24 * 60 * 60) -
                block.timestamp;
            return timeLeft;
        }
    }

    //END MEMBERSHIP CODE

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


    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }
}
