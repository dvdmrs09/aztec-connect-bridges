pragma solidity ^0.8.10;

interface ISpell3 {
    event AcceptGovernor(address governor);
    event SetGovernor(address governor);
    event SetPendingGovernor(address pendingGovernor);

    function acceptGovernor() external;
    function addLiquidity2(
        address lp,
        uint256[2] memory amtsUser,
        uint256 amtLPUser,
        uint256[2] memory amtsBorrow,
        uint256 amtLPBorrow,
        uint256 minLPMint,
        uint256 pid,
        uint256 gid
    )
        external;
    function addLiquidity3(
        address lp,
        uint256[3] memory amtsUser,
        uint256 amtLPUser,
        uint256[3] memory amtsBorrow,
        uint256 amtLPBorrow,
        uint256 minLPMint,
        uint256 pid,
        uint256 gid
    )
        external;
    function addLiquidity4(
        address lp,
        uint256[4] memory amtsUser,
        uint256 amtLPUser,
        uint256[4] memory amtsBorrow,
        uint256 amtLPBorrow,
        uint256 minLPMint,
        uint256 pid,
        uint256 gid
    )
        external;
    function approved(address, address) external view returns (bool);
    function bank() external view returns (address);
    function crv() external view returns (address);
    function ensureApproveN(address lp, uint256 n) external;
    function getPool(address lp) external returns (address);
    function governor() external view returns (address);
    function harvest() external;
    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory)
        external
        returns (bytes4);
    function onERC1155Received(address, address, uint256, uint256, bytes memory) external returns (bytes4);
    function pendingGovernor() external view returns (address);
    function poolOf(address) external view returns (address);
    function registry() external view returns (address);
    function removeLiquidity2(
        address lp,
        uint256 amtLPTake,
        uint256 amtLPWithdraw,
        uint256[2] memory amtsRepay,
        uint256 amtLPRepay,
        uint256[2] memory amtsMin
    )
        external;
    function removeLiquidity3(
        address lp,
        uint256 amtLPTake,
        uint256 amtLPWithdraw,
        uint256[3] memory amtsRepay,
        uint256 amtLPRepay,
        uint256[3] memory amtsMin
    )
        external;
    function removeLiquidity4(
        address lp,
        uint256 amtLPTake,
        uint256 amtLPWithdraw,
        uint256[4] memory amtsRepay,
        uint256 amtLPRepay,
        uint256[4] memory amtsMin
    )
        external;
    function setPendingGovernor(address _pendingGovernor) external;
    function setWhitelistLPTokens(address[] memory lpTokens, bool[] memory statuses) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function ulTokens(address, uint256) external view returns (address);
    function werc20() external view returns (address);
    function weth() external view returns (address);
    function wgauge() external view returns (address);
    function whitelistedLpTokens(address) external view returns (bool);
}
