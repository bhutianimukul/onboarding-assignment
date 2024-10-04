require "rspec"
require "./key_manager_v2.rb"

RSpec.describe ApiKeysControllerV2::KeyManagerV2 do
  describe "#add_key_to_pool" do
    key_manager = ApiKeysControllerV2::KeyManagerV2.new
    context "when adding a new key" do
      it "increases the key pool size" do
        expect { key_manager.add_key_to_pool }.to change { key_manager.key_pool.size }.by(1)
      end

      it "adds the key to the available keys set" do
        key = SecureRandom.hex(16)
        key_manager.add_key_to_pool({}, {}, key)
        expect(key_manager.available_keys).to include(key)
      end

      it "sets the correct expiry time" do
        key = SecureRandom.hex(16)
        key_manager.add_key_to_pool({}, {}, key)
        actual_expiry_time = key_manager.key_pool[key]
        expected_expiry_time = Time.now + ApiKeysControllerV2::KeyManagerV2::EXPIRY_TIME
        expect(actual_expiry_time).to be_within(1).of(expected_expiry_time)
      end
    end
  end

  describe "#get_available_keys" do
    key = SecureRandom.hex(16)
    key_manager = ApiKeysControllerV2::KeyManagerV2.new

    context "when there are no available keys" do
      it "returns :not_found status" do
        response = key_manager.get_available_keys
        expect(response).to eq([:not_found, "Unable to get any key from the key pool"])
      end
    end

    context "when there are available keys" do
      before do
        key_manager.add_key_to_pool({}, {}, key)
      end

      it "blocks the first available key and returns it" do
        response = key_manager.get_available_keys
        expect(response[0]).to eq(:ok)
        expect(key_manager.available_keys).not_to include(key)
        expect {
          key_manager.add_key_to_pool
          key_manager.get_available_keys
        }.to change { key_manager.blocked_keys.size }.by(+1)
      end
    end
  end
  describe "#unblock_key" do
    key = SecureRandom.hex(16)
    key_manager = ApiKeysControllerV2::KeyManagerV2.new
    context "when the key does not exist in the key pool" do
      it "returns :not_found status" do
        response = key_manager.unblock_key({}, { "key" => key })
        expect(response).to eq([:not_found, "Key not found"])
      end
    end

    context "when the key exists in the key pool" do
      key = ""
      before do
        key_manager.add_key_to_pool
        resp = key_manager.get_available_keys
        key = resp[1][:key]
      end
      it "removes the key from blocked keys" do
        expect { key_manager.unblock_key({}, { "key" => key }) }.to change { key_manager.blocked_keys.size }.by(-1)
      end
      it "returns :ok status on successful unblocking" do
        response = key_manager.unblock_key({}, { "key" => key })
        expect(response).to eq([:ok, "SUCCESS"])
      end
    end
  end
  describe "#purge_key" do
    key = SecureRandom.hex(16)
    key_manager = ApiKeysControllerV2::KeyManagerV2.new

    context "when the key does not exist in the key pool" do
      it "returns :not_found status" do
        response = key_manager.purge_key({}, { "key" => key })
        expect(response).to eq([:not_found, "Key not found"])
      end
    end

    context "when the key exists in the key pool" do
      before do
        key_manager.add_key_to_pool({}, {}, key)
      end

      it "removes the key from the key pool" do
        expect {
          key_manager.purge_key({}, { "key" => key })
        }.to change { key_manager.key_pool.size }.by(-1)
      end

      it "returns :ok status on successful purge" do
        response = key_manager.purge_key({}, { "key" => key })
        expect(response).to eq([:ok, "SUCCESS"])
      end
    end
  end
  describe '#keep_alive_cron' do
  key = SecureRandom.hex(16)
  key_manager = ApiKeysControllerV2::KeyManagerV2.new

  context 'when the key does not exist' do
    it 'returns :not_found status' do
      response = key_manager.keep_alive_cron({}, { "key" => key })
      expect(response).to eq([:not_found, "Key not found"])
    end
  end

  context 'when the key exists in the key pool' do
    before do
      key_manager.add_key_to_pool({}, {}, key)
    end

    context 'when the key is not yet expired' do
      it 'updates the expiry time' do
        initial_expiry_time = key_manager.key_pool[key]
        response = key_manager.keep_alive_cron({}, { "key" => key })

        expect(response).to eq([:ok, "SUCCESS"])
        expect(key_manager.key_pool[key]).to be > initial_expiry_time
      end

    end

    context 'when the key has already expired' do
      before do
        key_manager.key_pool[key] = Time.now - (ApiKeysControllerV2::KeyManagerV2::EXPIRY_TIME + 1)
      end

      it 'returns a message indicating the key is already refreshed or expired' do
        response = key_manager.keep_alive_cron({}, { "key" => key })
        expect(response).to eq([:ok, "Key is Already refreshed or expired"])
      end
    end
  end
end
end
