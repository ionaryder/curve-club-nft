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

    uint256 public MAX_SUPPLY = 100;
    uint256 public constant MAX_CURVE_MINT = 1;
    uint256 public price = 0.1 ether;

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

        function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _tokenId <= _tokenIds.current(),
            "ERC721Metadata: URI query for nonexistent token"
        );
        if (isRevealed == false) {
            return notRevealedUri;
        }

        string memory uriStart = "https://gateway.pinata.cloud/ipfs/";
        string memory uriEnd = ".json";

        return
            string(
                abi.encodePacked(
                    uriStart,
                    cid,
                    "/",
                    _tokenId.toString(),
                    uriEnd
                )
            );
    }


    function setActive(bool change) public onlyOwner {
        isSaleActive = change;
    }

    // set nft price
    function setPrice(uint256 _newPrice) external onlyOwner {
        price = _newPrice;
    }

    function setMaxSupply(uint256 _supply) external onlyOwner {
        MAX_SUPPLY = _supply;
    }


    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setRevealed(bool _state) public onlyOwner {
        isRevealed = _state;
    }

    function revokeMembership(uint256 tokenId) onlyOwner external {
        dateMinted[ownerOf(tokenId)] = 0;
        _burn(tokenId);
    }

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

    function setOnlyWhitelisted(bool _state) public onlyOwner {
        onlyWhiteListed = _state;
    }

    function whitelistUsers(address[] calldata _users) public onlyOwner {
        delete whitelistedAddresses;
        whitelistedAddresses = _users;
    }

    function isWhitelisted(address _user) public view returns (bool) {
        for (uint256 i = 0; i < whitelistedAddresses.length; i++) {
            if (whitelistedAddresses[i] == _user) {
                return true;
            }
        }
        return false;
    }

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

    function withdraw() public payable onlyOwner nonReentrant {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }


}
