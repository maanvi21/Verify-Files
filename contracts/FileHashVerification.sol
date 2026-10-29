// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title FileHashVerification
 * @notice A decentralized system for storing and verifying file hashes on-chain.
 *         Users can register a file's SHA-256 hash along with a filename. Later,
 *         anyone can verify whether a file hash was previously registered and by whom.
 */
contract FileHashVerification {

    // ─── Data Structures ────────────────────────────────────────────────

    struct FileRecord {
        address owner;       // The address that registered the hash
        string  fileName;    // Human-readable filename
        uint256 timestamp;   // Block timestamp when the hash was stored
        bool    exists;      // Guard flag for existence checks
    }

    // ─── State ──────────────────────────────────────────────────────────

    /// @notice Mapping from file hash → record
    mapping(bytes32 => FileRecord) private fileRecords;

    /// @notice All hashes registered by a given address
    mapping(address => bytes32[]) private userFiles;

    /// @notice Total number of files registered on the contract
    uint256 public totalFiles;

    // ─── Events ─────────────────────────────────────────────────────────

    /// @notice Emitted when a new file hash is successfully registered
    event FileRegistered(
        bytes32 indexed fileHash,
        address indexed owner,
        string  fileName,
        uint256 timestamp
    );

    // ─── Modifiers ──────────────────────────────────────────────────────

    modifier hashNotRegistered(bytes32 _fileHash) {
        require(!fileRecords[_fileHash].exists, "File hash already registered");
        _;
    }

    modifier hashExists(bytes32 _fileHash) {
        require(fileRecords[_fileHash].exists, "File hash not found");
        _;
    }

    // ─── Core Functions ─────────────────────────────────────────────────

    /**
     * @notice Register a new file hash on-chain.
     * @param _fileHash  The SHA-256 hash of the file (passed as bytes32).
     * @param _fileName  A human-readable name for the file.
     */
    function registerFile(bytes32 _fileHash, string calldata _fileName)
        external
        hashNotRegistered(_fileHash)
    {
        require(_fileHash != bytes32(0), "Invalid file hash");
        require(bytes(_fileName).length > 0, "File name cannot be empty");

        fileRecords[_fileHash] = FileRecord({
            owner:     msg.sender,
            fileName:  _fileName,
            timestamp: block.timestamp,
            exists:    true
        });

        userFiles[msg.sender].push(_fileHash);
        totalFiles++;

        emit FileRegistered(_fileHash, msg.sender, _fileName, block.timestamp);
    }

    /**
     * @notice Verify whether a file hash has been registered.
     * @param _fileHash The hash to look up.
     * @return isRegistered  True if the hash exists on-chain.
     * @return owner         The address that registered it (0x0 if not found).
     * @return fileName      The stored filename (empty if not found).
     * @return timestamp     The registration timestamp (0 if not found).
     */
    function verifyFile(bytes32 _fileHash)
        external
        view
        returns (
            bool    isRegistered,
            address owner,
            string  memory fileName,
            uint256 timestamp
        )
    {
        FileRecord storage record = fileRecords[_fileHash];
        return (record.exists, record.owner, record.fileName, record.timestamp);
    }

    /**
     * @notice Get the details of a registered file hash.
     * @param _fileHash The hash to look up.
     * @return owner     The registering address.
     * @return fileName  The stored filename.
     * @return timestamp The registration timestamp.
     */
    function getFileDetails(bytes32 _fileHash)
        external
        view
        hashExists(_fileHash)
        returns (
            address owner,
            string  memory fileName,
            uint256 timestamp
        )
    {
        FileRecord storage record = fileRecords[_fileHash];
        return (record.owner, record.fileName, record.timestamp);
    }

    /**
     * @notice Get all file hashes registered by a specific address.
     * @param _user The address to query.
     * @return An array of bytes32 hashes.
     */
    function getUserFiles(address _user)
        external
        view
        returns (bytes32[] memory)
    {
        return userFiles[_user];
    }

    /**
     * @notice Check if a specific file hash is already registered.
     * @param _fileHash The hash to check.
     * @return True if the hash exists on-chain.
     */
    function isFileRegistered(bytes32 _fileHash)
        external
        view
        returns (bool)
    {
        return fileRecords[_fileHash].exists;
    }
}
