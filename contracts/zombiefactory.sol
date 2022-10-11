// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "./ownable.sol";

// ゾンビの外見は「ゾンビDNA」によって決まる。
// ゾンビDNAは16桁の整数である
// 頭部、目、シャツ、肌、目の色、服の色、　　　　、猫ゾンビ

contract ZombieFactory is Ownable{
    constructor() {
        
    }

    // ゾンビが配列に格納された際のイベントを定義する
    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits; // 10の16乗
    uint cooldownTime = 1 days;

    // 複数のゾンビのプロパティをもつ構造体の定義
    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
    }

    // ゾンビ構造体の配列を定義
    Zombie[] public zombies;

    // ゾンビを所有するオーナーを格納するアドレスを定義
    mapping (uint => address) public zombieToOwner; // idをもとに所有者のアドレス
    mapping (address => uint) ownerZombieCount; // アドレスからゾンビ

    // ゾンビを配列に格納する関数
    function _createZombie(string memory _name, uint _dna) internal {
        // array.push()は、zombies配列に要素を追加する
        zombies.push( Zombie(_name, _dna, 1, uint32(block.timestamp + cooldownTime)) );

        // 配列のインデックスを作成する　**配列は0オリジンなので -1
        uint id = zombies.length - 1;

        // マッピングを更新する
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;

        // イベントを発生させる
        emit NewZombie(id, _name, _dna);
    }

    // 乱数(ゾンビDNA)を作成する関数
    function _generateRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str))); // ハッシュ関数
        return rand % dnaModulus; // 16桁に揃える
    }

    //                *** 実際の呼び出される関数はコレ ***
    // ゾンビを作成する関数
    function createRandomZombie(string memory _name) public {
        // ゾンビを持っていないアドレスのみこの関数を実行できる
        require(ownerZombieCount[msg.sender] == 0);

        // まず、名前からゾンビDNAを作成する
        uint randDna = _generateRandomDna(_name);

        // 名前とゾンビDNAを構造体とし、zombies配列に格納する
        _createZombie(_name, randDna);
    }
}