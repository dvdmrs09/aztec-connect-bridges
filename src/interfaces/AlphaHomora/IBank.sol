pragma solidity ^0.8.10;

interface HomoraBank {
    event AcceptGovernor(address governor);
    event AddBank(address token, address cToken);
    event Borrow(uint256 positionId, address caller, address token, uint256 amount, uint256 share);
    event Liquidate(
        uint256 positionId, address liquidator, address debtToken, uint256 amount, uint256 share, uint256 bounty
    );
    event PutCollateral(uint256 positionId, address caller, address token, uint256 id, uint256 amount);
    event Repay(uint256 positionId, address caller, address token, uint256 amount, uint256 share);
    event SetFeeBps(uint256 feeBps);
    event SetGovernor(address governor);
    event SetOracle(address oracle);
    event SetPendingGovernor(address pendingGovernor);
    event TakeCollateral(uint256 positionId, address caller, address token, uint256 id, uint256 amount);
    event WithdrawReserve(address user, address token, uint256 amount);

    function EXECUTOR() external view returns (address);
    function POSITION_ID() external view returns (uint256);
    function SPELL() external view returns (address);
    function _GENERAL_LOCK() external view returns (uint256);
    function _IN_EXEC_LOCK() external view returns (uint256);
    function acceptGovernor() external;
    function accrue(address token) external;
    function accrueAll(address[] memory tokens) external;
    function addBank(address token, address cToken) external;
    function allBanks(uint256) external view returns (address);
    function allowBorrowStatus() external view returns (bool);
    function allowContractCalls() external view returns (bool);
    function allowRepayStatus() external view returns (bool);
    function bankStatus() external view returns (uint256);
    function banks(address)
        external
        view
        returns (bool isListed, uint8 index, address cToken, uint256 reserve, uint256 totalDebt, uint256 totalShare);
    function borrow(address token, uint256 amount) external;
    function borrowBalanceCurrent(uint256 positionId, address token) external returns (uint256);
    function borrowBalanceStored(uint256 positionId, address token) external view returns (uint256);
    function cTokenInBank(address) external view returns (bool);
    function caster() external view returns (address);
    function execute(uint256 positionId, address spell, bytes memory data) external payable returns (uint256);
    function feeBps() external view returns (uint256);
    function getBankInfo(address token)
        external
        view
        returns (bool isListed, address cToken, uint256 reserve, uint256 totalDebt, uint256 totalShare);
    function getBorrowETHValue(uint256 positionId) external view returns (uint256);
    function getCollateralETHValue(uint256 positionId) external view returns (uint256);
    function getCurrentPositionInfo()
        external
        view
        returns (address owner, address collToken, uint256 collId, uint256 collateralSize);
    function getPositionDebtShareOf(uint256 positionId, address token) external view returns (uint256);
    function getPositionDebts(uint256 positionId)
        external
        view
        returns (address[] memory tokens, uint256[] memory debts);
    function getPositionInfo(uint256 positionId)
        external
        view
        returns (address owner, address collToken, uint256 collId, uint256 collateralSize);
           function governor() external view returns (address);
    function initialize(address _oracle, uint256 _feeBps) external;
    function liquidate(uint256 positionId, address debtToken, uint256 amountCall) external;
    function nextPositionId() external view returns (uint256);
    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory)
        external
        returns (bytes4);
    function onERC1155Received(address, address, uint256, uint256, bytes memory) external returns (bytes4);
    function oracle() external view returns (address);
    function pendingGovernor() external view returns (address);
    function positions(uint256)
        external
        view
        returns (address owner, address collToken, uint256 collId, uint256 collateralSize, uint256 debtMap);
    function putCollateral(address collToken, uint256 collId, uint256 amountCall) external;
    function repay(address token, uint256 amountCall) external;
    function setAllowContractCalls(bool ok) external;
    function setBankStatus(uint256 _bankStatus) external;
    function setFeeBps(uint256 _feeBps) external;
    function setOracle(address _oracle) external;
    function setPendingGovernor(address _pendingGovernor) external;
    function setWhitelistSpells(address[] memory spells, bool[] memory statuses) external;
    function setWhitelistTokens(address[] memory tokens, bool[] memory statuses) external;
    function setWhitelistUsers(address[] memory users, bool[] memory statuses) external;
    function support(address token) external view returns (bool);
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function takeCollateral(address collToken, uint256 collId, uint256 amount) external;
    function transmit(address token, uint256 amount) external;
    function whitelistedSpells(address) external view returns (bool);
    function whitelistedTokens(address) external view returns (bool);
    function whitelistedUsers(address) external view returns (bool);
    function withdrawReserve(address token, uint256 amount) external;
    }
