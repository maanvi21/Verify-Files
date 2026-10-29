const FileHashVerification = artifacts.require("FileHashVerification");

contract("FileHashVerification", (accounts) => {
    let instance;
    const owner   = accounts[0];
    const other   = accounts[1];
    // Pre-computed SHA-256 of the string "hello world"
    const testHash = "0xb94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9";
    const fileName = "hello.txt";

    beforeEach(async () => {
        instance = await FileHashVerification.new();
    });

    it("should register a file hash", async () => {
        const tx = await instance.registerFile(testHash, fileName, { from: owner });

        // Check event
        assert.equal(tx.logs[0].event, "FileRegistered");
        assert.equal(tx.logs[0].args.fileHash, testHash);
        assert.equal(tx.logs[0].args.owner, owner);
        assert.equal(tx.logs[0].args.fileName, fileName);

        // totalFiles should be 1
        const total = await instance.totalFiles();
        assert.equal(total.toNumber(), 1);
    });

    it("should NOT allow duplicate registration", async () => {
        await instance.registerFile(testHash, fileName, { from: owner });
        try {
            await instance.registerFile(testHash, "other.txt", { from: other });
            assert.fail("Expected revert not received");
        } catch (err) {
            assert(err.message.includes("File hash already registered"));
        }
    });

    it("should verify a registered file", async () => {
        await instance.registerFile(testHash, fileName, { from: owner });
        const res = await instance.verifyFile(testHash);

        assert.equal(res.isRegistered, true);
        assert.equal(res.owner, owner);
        assert.equal(res.fileName, fileName);
        assert(res.timestamp.toNumber() > 0);
    });

    it("should return false for unregistered hash", async () => {
        const fakeHash = "0x" + "ab".repeat(32);
        const res = await instance.verifyFile(fakeHash);
        assert.equal(res.isRegistered, false);
    });

    it("should return user files list", async () => {
        await instance.registerFile(testHash, fileName, { from: owner });
        const files = await instance.getUserFiles(owner);
        assert.equal(files.length, 1);
        assert.equal(files[0], testHash);
    });

    it("should reject empty file name", async () => {
        try {
            await instance.registerFile(testHash, "", { from: owner });
            assert.fail("Expected revert not received");
        } catch (err) {
            assert(err.message.includes("File name cannot be empty"));
        }
    });

    it("should reject zero hash", async () => {
        const zeroHash = "0x" + "00".repeat(32);
        try {
            await instance.registerFile(zeroHash, fileName, { from: owner });
            assert.fail("Expected revert not received");
        } catch (err) {
            assert(err.message.includes("Invalid file hash"));
        }
    });
});
