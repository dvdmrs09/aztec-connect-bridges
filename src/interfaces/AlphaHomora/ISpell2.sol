pragma solidity ^0.8.10;

interface ISpell2 {
    event AcceptGovernor(address governor);
    event SetGovernor(address governor);
    event SetPendingGovernor(address pendingGovernor);

    struct Amounts {
        uint256 a;
        uint256 b;
        uint256 c;
        uint256 d;
        uint256 e;
        uint256 f;
        uint256 g;
        uint256 h;
    }

    struct RepayAmounts {
        uint256 a;
        uint256 b;
        uint256 c;
        uint256 d;
        uint256 e;
        uint256 f;
        uint256 g;
    }

    function acceptGovernor() external;
    function addLiquidityWERC20(address tokenA, address tokenB, Amounts memory amt) external payable;
    function addLiquidityWMasterChef(address tokenA, address tokenB, Amounts memory amt, uint256 pid)
        external
        payable;
    function approved(address, address) external view returns (bool);
    function bank() external view returns (address);
    function factory() external view returns (address);
    function getAndApprovePair(address tokenA, address tokenB) external returns (address);
    function governor() external view returns (address);
    function harvestWMasterChef() external;
    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory)
        external
        returns (bytes4);
    function onERC1155Received(address, address, uint256, uint256, bytes memory) external returns (bytes4);
    function pairs(address, address) external view returns (address);
    function pendingGovernor() external view returns (address);
    function removeLiquidityWERC20(address tokenA, address tokenB, RepayAmounts memory amt) external;
    function removeLiquidityWMasterChef(address tokenA, address tokenB, RepayAmounts memory amt) external;
    function router() external view returns (address);
    function setPendingGovernor(address _pendingGovernor) external;
    function setWhitelistLPTokens(address[] memory lpTokens, bool[] memory statuses) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function sushi() external view returns (address);
    function werc20() external view returns (address);
    function weth() external view returns (address);
    function whitelistedLpTokens(address) external view returns (bool);
    function wmasterchef() external view returns (address);
}
