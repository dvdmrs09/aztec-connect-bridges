import {
  BaseContract,
  BigNumber,
  BigNumberish,
  BytesLike,
  CallOverrides,
  ContractTransaction,
  PayableOverrides,
  PopulatedTransaction,
  Signer,
  utils,
} from "ethers";
import { FunctionFragment, Result } from "@ethersproject/abi";
import { Listener, Provider } from "@ethersproject/providers";
import { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "./common";

export declare namespace AztecTypes {
  export type AztecAssetStruct = {
    id: BigNumberish;
    erc20Address: string;
    assetType: BigNumberish;
  };

  export type AztecAssetStructOutput = [BigNumber, string, number] & {
    id: BigNumber;
    erc20Address: string;
    assetType: number;
  };
}

export interface AlphaHomorabridgeInterface extends utils.Interface {
  contractName: "AlphaHomorabridge";
  functions: {
    "BANK()": FunctionFragment;
    "SPELL()": FunctionFragment;
    "convert((uint256,address,uint8),(uint256,address,uint8),(uint256,address,uint8),(uint256,address,uint8),uint256,uint256,uint64,address)": FunctionFragment;
    "deposit(address,address,uint256,uint256,uint256,bytes)": FunctionFragment;
    "finalise((uint256,address,uint8),(uint256,address,uint8),(uint256,address,uint8),(uint256,address,uint8),uint256,uint64)": FunctionFragment;
  };

  encodeFunctionData(functionFragment: "BANK", values?: undefined): string;
  encodeFunctionData(functionFragment: "SPELL", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "convert",
    values: [
      AztecTypes.AztecAssetStruct,
      AztecTypes.AztecAssetStruct,
      AztecTypes.AztecAssetStruct,
      AztecTypes.AztecAssetStruct,
      BigNumberish,
      BigNumberish,
      BigNumberish,
      string
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "deposit",
    values: [
      string,
      string,
      BigNumberish,
      BigNumberish,
      BigNumberish,
      BytesLike
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "finalise",
    values: [
      AztecTypes.AztecAssetStruct,
      AztecTypes.AztecAssetStruct,
      AztecTypes.AztecAssetStruct,
      AztecTypes.AztecAssetStruct,
      BigNumberish,
      BigNumberish
    ]
  ): string;

  decodeFunctionResult(functionFragment: "BANK", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "SPELL", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "convert", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "deposit", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "finalise", data: BytesLike): Result;

  events: {};
}

export interface AlphaHomorabridge extends BaseContract {
  contractName: "AlphaHomorabridge";
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: AlphaHomorabridgeInterface;

  queryFilter<TEvent extends TypedEvent>(
    event: TypedEventFilter<TEvent>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TEvent>>;

  listeners<TEvent extends TypedEvent>(
    eventFilter?: TypedEventFilter<TEvent>
  ): Array<TypedListener<TEvent>>;
  listeners(eventName?: string): Array<Listener>;
  removeAllListeners<TEvent extends TypedEvent>(
    eventFilter: TypedEventFilter<TEvent>
  ): this;
  removeAllListeners(eventName?: string): this;
  off: OnEvent<this>;
  on: OnEvent<this>;
  once: OnEvent<this>;
  removeListener: OnEvent<this>;

  functions: {
    BANK(overrides?: CallOverrides): Promise<[string]>;

    SPELL(overrides?: CallOverrides): Promise<[string]>;

    convert(
      _inputAssetA: AztecTypes.AztecAssetStruct,
      _inputAssetB: AztecTypes.AztecAssetStruct,
      arg2: AztecTypes.AztecAssetStruct,
      arg3: AztecTypes.AztecAssetStruct,
      arg4: BigNumberish,
      _interactionNonce: BigNumberish,
      arg6: BigNumberish,
      arg7: string,
      overrides?: PayableOverrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    deposit(
      _inputAssetA: string,
      _inputAssetB: string,
      outputValueA: BigNumberish,
      outputValueB: BigNumberish,
      positionId: BigNumberish,
      data: BytesLike,
      overrides?: PayableOverrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    finalise(
      arg0: AztecTypes.AztecAssetStruct,
      arg1: AztecTypes.AztecAssetStruct,
      arg2: AztecTypes.AztecAssetStruct,
      arg3: AztecTypes.AztecAssetStruct,
      arg4: BigNumberish,
      arg5: BigNumberish,
      overrides?: PayableOverrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;
  };

  BANK(overrides?: CallOverrides): Promise<string>;

  SPELL(overrides?: CallOverrides): Promise<string>;

  convert(
    _inputAssetA: AztecTypes.AztecAssetStruct,
    _inputAssetB: AztecTypes.AztecAssetStruct,
    arg2: AztecTypes.AztecAssetStruct,
    arg3: AztecTypes.AztecAssetStruct,
    arg4: BigNumberish,
    _interactionNonce: BigNumberish,
    arg6: BigNumberish,
    arg7: string,
    overrides?: PayableOverrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  deposit(
    _inputAssetA: string,
    _inputAssetB: string,
    outputValueA: BigNumberish,
    outputValueB: BigNumberish,
    positionId: BigNumberish,
    data: BytesLike,
    overrides?: PayableOverrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  finalise(
    arg0: AztecTypes.AztecAssetStruct,
    arg1: AztecTypes.AztecAssetStruct,
    arg2: AztecTypes.AztecAssetStruct,
    arg3: AztecTypes.AztecAssetStruct,
    arg4: BigNumberish,
    arg5: BigNumberish,
    overrides?: PayableOverrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  callStatic: {
    BANK(overrides?: CallOverrides): Promise<string>;

    SPELL(overrides?: CallOverrides): Promise<string>;

    convert(
      _inputAssetA: AztecTypes.AztecAssetStruct,
      _inputAssetB: AztecTypes.AztecAssetStruct,
      arg2: AztecTypes.AztecAssetStruct,
      arg3: AztecTypes.AztecAssetStruct,
      arg4: BigNumberish,
      _interactionNonce: BigNumberish,
      arg6: BigNumberish,
      arg7: string,
      overrides?: CallOverrides
    ): Promise<
      [BigNumber, BigNumber, boolean] & {
        outputValueA: BigNumber;
        outputValueB: BigNumber;
      }
    >;

    deposit(
      _inputAssetA: string,
      _inputAssetB: string,
      outputValueA: BigNumberish,
      outputValueB: BigNumberish,
      positionId: BigNumberish,
      data: BytesLike,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    finalise(
      arg0: AztecTypes.AztecAssetStruct,
      arg1: AztecTypes.AztecAssetStruct,
      arg2: AztecTypes.AztecAssetStruct,
      arg3: AztecTypes.AztecAssetStruct,
      arg4: BigNumberish,
      arg5: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[BigNumber, BigNumber, boolean]>;
  };

  filters: {};

  estimateGas: {
    BANK(overrides?: CallOverrides): Promise<BigNumber>;

    SPELL(overrides?: CallOverrides): Promise<BigNumber>;

    convert(
      _inputAssetA: AztecTypes.AztecAssetStruct,
      _inputAssetB: AztecTypes.AztecAssetStruct,
      arg2: AztecTypes.AztecAssetStruct,
      arg3: AztecTypes.AztecAssetStruct,
      arg4: BigNumberish,
      _interactionNonce: BigNumberish,
      arg6: BigNumberish,
      arg7: string,
      overrides?: PayableOverrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;

    deposit(
      _inputAssetA: string,
      _inputAssetB: string,
      outputValueA: BigNumberish,
      outputValueB: BigNumberish,
      positionId: BigNumberish,
      data: BytesLike,
      overrides?: PayableOverrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;

    finalise(
      arg0: AztecTypes.AztecAssetStruct,
      arg1: AztecTypes.AztecAssetStruct,
      arg2: AztecTypes.AztecAssetStruct,
      arg3: AztecTypes.AztecAssetStruct,
      arg4: BigNumberish,
      arg5: BigNumberish,
      overrides?: PayableOverrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    BANK(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    SPELL(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    convert(
      _inputAssetA: AztecTypes.AztecAssetStruct,
      _inputAssetB: AztecTypes.AztecAssetStruct,
      arg2: AztecTypes.AztecAssetStruct,
      arg3: AztecTypes.AztecAssetStruct,
      arg4: BigNumberish,
      _interactionNonce: BigNumberish,
      arg6: BigNumberish,
      arg7: string,
      overrides?: PayableOverrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;

    deposit(
      _inputAssetA: string,
      _inputAssetB: string,
      outputValueA: BigNumberish,
      outputValueB: BigNumberish,
      positionId: BigNumberish,
      data: BytesLike,
      overrides?: PayableOverrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;

    finalise(
      arg0: AztecTypes.AztecAssetStruct,
      arg1: AztecTypes.AztecAssetStruct,
      arg2: AztecTypes.AztecAssetStruct,
      arg3: AztecTypes.AztecAssetStruct,
      arg4: BigNumberish,
      arg5: BigNumberish,
      overrides?: PayableOverrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;
  };
}
