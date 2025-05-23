// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ChainZNative is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    ERC20PausableUpgradeable
{
    address private mtzAdmin;
    address public dao;

    mapping (address => bool) internal blackList;

    event AddedBlackList(address user);

    event RemovedBlackList(address user);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // Modifier that allows only the admin to call a function
    modifier onlyAdmin() {
        require(
            msg.sender == mtzAdmin,
            "Unauthorized: caller is not the admin"
        );
        _;
    }
    modifier onlyDao() {
        require(msg.sender == dao, "Unauthorized: caller is not the dao admin");
        _;
    }

    function initialize(address _dao) public initializer {
        UUPSUpgradeable.__UUPSUpgradeable_init();
        OwnableUpgradeable.__Ownable_init(_dao);
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
        __ERC20_init("CHAINZ", "CHZ");
        __ERC20Burnable_init();
        __ERC20Pausable_init();

        _mint(msg.sender, 10_000_000_000 * 10 ** decimals());
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal virtual override onlyOwner {}

      function isBlackListed(address maker) public view returns (bool) {
        return blackList[maker];
    }
    
    function addBlackList (address evilUser) public onlyAdmin {
        blackList[evilUser] = true;
        emit AddedBlackList(evilUser);
    }

    function removeBlackList (address clearedUser) public onlyAdmin {
        blackList[clearedUser] = false;
        emit RemovedBlackList(clearedUser);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyDao nonReentrant() {
        _mint(to, amount);
    }

      function burn(address account, uint256 amount) public onlyDao nonReentrant() {
        _burn(account, amount);
    }


    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20Upgradeable, ERC20PausableUpgradeable) {
        super._update(from, to, value);
    }
}
