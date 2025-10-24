//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC4626.sol";
//ws-omnidragon
//just deploy two of thse no need for two similar vault contracts
contract AssetVault is ERC4626 {
    // a mapping that checks if a user has deposited the token
    //seems like strign balances locally is beter
  
    mapping(address => uint256) public assetsDeposited;
    VaultUnifier vaultUnifier;

    //handles dragon deposits
    //this decides what mapping we use asset
    bool isMultiAssetVault;
    ERC20 public asset;
    constructor(
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC4626(_asset, _name, _symbol) {
        asset = _asset;
    }

    //max withdraw get share abalances of user, how much they have deposited
    /**
     * @notice function to deposit assets and receive vault tokens in exchange
     * @param _assets amount of the asset token
     */
    //  Sonic (hub) is the main vault. It’s where the real tokens are kept and where the real deposits and withdrawals happen.

    funtion _getAssetsDeposited() returns (EC20){

        return asset;
    }

//approves spending for an asset 
    function approveSpending(address _spender, uint256 _amount)override private{
      asset.approve(_spender, _amount);
    }

//this must be set before depositing liquidity into our position 
    function setVaultUnifier(VaultUnifier _vaultUnifier){
        //add a requrement in which owner can only changethis will be stricter when we refactor 
        vaultUnifier = _vaultUnifier;
    }

//this is a very vulnerable fnction secure this function tightly
//function names and code will be refactored just laying out the flow first:)
//vault unifer must be set before calling this 
    function excecuteWithdraw(address _user)private return(uint256) {
        //frm, to , amount

        //require block checks if vaultunifer is present 
        require(vaultUnifier !== address(0), "VaultUnifier not defined!");
        uint256 _amountWithdrawn =  assestsDeposited[_user];
        //transfers to vault unifier
        asset.transferFrom(address(this), vaultUnifier, _amountWithdrawn);

        return _amountWithdrawn;
    }

//code gets leaned upone flow gets layed out properly***
    function _deposit(uint256 _assets, address _user) public {
        // checks that the deposited amount is greater than zero.
        require(_assets > 0, "Deposit less than Zero");
        // calling the deposit function from the ERC-4626 library to perform all the necessary functionality
        //the deeposit transfers the callers tokens of the asset into the contract its built in the erc46426
        //uses safeTransferFrom(msg.sender, address(this), _assets)
        deposit(_assets);
        // Increase the share of the user
        assetsDeposited[_user] += _assets;
    }

    /**
     * @notice Function to allow msg.sender to withdraw their deposit plus accrued interest
     * @param _shares amount of shares the user wants to convert
     * @param _receiver address of the user who will receive the assets
     */
    function _withdraw(uint256 _shares, address _receiver) public {
        // checks that the deposited amount is greater than zero.
        require(_shares > 0, "withdraw must be greater than Zero");
        // Checks that the _receiver address is not zero.
        require(_receiver != address(0), "Zero Address");
        // checks that the caller is a shareholder
        require(shareHolder[msg.sender] > 0, "Not a share holder");
        // checks that the caller has more shares than they are trying to withdraw.
        require(shareHolder[msg.sender] >= _shares, "Not enough shares");

        // calling the redeem function from the ERC-4626 library to perform all the necessary functionality
        redeem(_shares, _receiver, msg.sender);
        // Decrease the share of the user
        assetsDeposited[msg.sender] -= _shares;
    }

    // returns total number of assets
    //returns total shares that have been minted by every user of the contract
    function getAmountDeposited(address _owner) public view override returns (uint256) {
        //returns the balance on the user the balance thy have deposited
        return assets[_owner];
    }

    function updateAmountDeposited(uint256 _assets, address _user)public{
        assetsDeposited[user] = _assets;
    }

    // returns total balance of user
    //balance of tokens user has balance of asset we can deposit into the vault
    // function totalAssetsOfUser(address _user) public view returns (uint256) {
    //     return asset.balanceOf(_user);
    // }

    function setAssets(address owner, uint256 _assets) external {
        //this we call when we check the current position of the asset deposited in the lp position in the unifier there wil be a function to simotaneously update both asset balances
        //the position getting will always be called on the frontend
        shareHolder[owner] = _assets;
    }

    
}
