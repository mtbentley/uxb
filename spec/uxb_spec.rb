require 'uxb'
RSpec.describe Connector do
  describe 'init' do
    it 'initializes properly' do
      conn = Connector.new('device', 10, :computer)
      expect(conn.type).to eq(:computer)
      expect(conn.index).to eq(10)
      expect(conn.peer).to eq(nil)
      expect(conn.device).to eq('device')
    end
  end
end

RSpec.describe BinaryMessage do
  describe 'init' do
    it 'initializes properly' do
      message = BinaryMessage.new(100)
      expect(message.value).to eq(100)
    end
  end
  describe 'equals' do
    it 'works' do
      message1 = BinaryMessage.new(100)
      message2 = BinaryMessage.new(100)
      message3 = BinaryMessage.new(101)

      expect(message1 == message2)
      expect(message1 != message3)
    end
  end
end

RSpec.describe Hub::Builder do
  before(:each) do
    @hub_builder = Hub::Builder.new(10)
  end
  describe 'initialization' do
    it 'works' do
      expect(@hub_builder.version).to eq(10)
    end
  end
  describe 'building' do
    it 'works with no product_code' do
      expect(@hub_builder.product_code).to eq(nil)
    end
    it 'works with no serial_number' do
      expect(@hub_builder.serial_number).to eq(nil)
    end
    it 'works with product_code' do
      @hub_builder.product_code = 101
      expect(@hub_builder.product_code).to eq(101)
    end
    it 'works with serial_number' do
      @hub_builder.serial_number = 1001
      expect(@hub_builder.serial_number).to eq(1001)
    end
    it 'works with no connectors' do
      expect(@hub_builder.connectors).to be_empty
    end
    it 'works with some connectors' do
      @hub_builder.connectors = [Connector.new(nil, nil, nil),
                                 Connector.new(nil, nil, nil)]
      expect(@hub_builder.connectors.length).to be(2)
    end
  end
  describe 'validation' do
    it 'works when everything is in place' do
      @hub_builder.connectors = [Connector.new(nil, nil, :computer),
                                 Connector.new(nil, nil, :peripheral)]
      expect(@hub_builder.validate)
    end
    it 'fails when there is no peripheral' do
      @hub_builder.connectors = [Connector.new(nil, nil, :computer)]
      expect { @hub_builder.validate }.to raise_exception
    end
    it 'fails when there is no computer' do
      @hub_builder.connectors = [Connector.new(nil, nil, :peripheral)]
      expect { @hub_builder.validate }.to raise_exception
    end
    it 'fails when the version is nil' do
      nil_hub = Hub::Builder.new(nil)
      nil_hub.connectors = [Connector.new(nil, nil, :computer),
                            Connector.new(nil, nil, :peripheral)]
      expect { nil_hub.validate }.to raise_exception
    end
  end
end

RSpec.describe Hub do
  describe 'building' do
    it 'works' do
      hub_builder = Hub::Builder.new(11)
      hub_builder.product_code = 101
      hub_builder.serial_number = 1001
      hub_builder.connectors = [Connector.new(nil, nil, :computer),
                                Connector.new(nil, nil, :peripheral)]
      hub = hub_builder.build
      expect(hub.product_code).to eq(101)
      expect(hub.version).to eq(11)
      expect(hub.serial_number).to eq(1001)
      expect(hub.connector_count).to eq(2)
      expect(hub.device_class).to eq(:hub)
    end
  end
end
