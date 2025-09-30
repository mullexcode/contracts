// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

interface IMintableToken is IERC20{
    /**
     * @dev 
     * @param to 
     * @param amount 
     */
    function mint(address to, uint256 amount) external;

    /**
     * @dev 
     * @param account 
     * @param amount 
     */
    function burnByOwner(address account, uint256 amount) external;
}

contract UpgradeableToken is Initializable, ERC20Upgradeable, OwnableUpgradeable, UUPSUpgradeable, IMintableToken {
    uint8 private _decimals;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory name, 
        string memory symbol, 
        uint8 decimals_
    ) initializer public {
        __ERC20_init(name, symbol);
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        _decimals = decimals_;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
     * @dev 
     */
    function decimals() public view override(ERC20Upgradeable) returns (uint8) {
        return _decimals;
    }

    /**
     * @dev 
     * @param to 
     * @param amount 
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev 
     * @param from 
     * @param amount 
     */
    function burnByOwner(address from, uint256 amount) public onlyOwner {
        _burn(from, amount);
    }

    /**
     * @dev 
     * @param amount 
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    /**
     * @dev 
     * @param spender 
     * @param amount 
     * @return 
     */
    function approve(address spender, uint256 amount) public override(ERC20Upgradeable, IERC20) returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev 
     * @param spender 
     * @param addedValue 
     * @return 
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, allowance(_msgSender(), spender) + addedValue);
        return true;
    }

    /**
     * @dev 
     * @param spender 
     * @param subtractedValue 
     * @return 
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = allowance(_msgSender(), spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }
}

