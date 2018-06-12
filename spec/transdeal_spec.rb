require 'spec_helper'

RSpec.describe Transdeal do
  it 'has a version number' do
    expect(Transdeal::VERSION).not_to be nil
  end

  def update_whatevers(*targets)
    [*?a..?z, *?A..?Z, *?0..?9].sample(16).join.tap do |value| # make it property-tested
      targets.each do |target|
        case (1..4).to_a.sample
        when 1 then target.update_attributes!(whatever: value)
        when 2 then target.update_column(:whatever, value)
        when 3 then target.tap { |t| t.whatever = value }.save
        when 4 then target.tap { |t| t.whatever = value }.save!
        end
      end
    end
  end

  def check_whatevers(value, *targets)
    targets.all? { |target| target.reload.whatever == value }
  end

  let(:configurator) { ->(data) { puts data.inspect } }
  before { Transdeal.instance_variable_set(:@🏺, nil) }

  ##############################################################################

  context 'configuration' do
    it 'allows configuration' do
      expect { Transdeal.configure(&configurator) }.to \
        change { Transdeal.instance_variable_get(:@🏺) }.from(nil).to([configurator])
    end
  end

  ##############################################################################

  context 'execution' do
    let!(:master1) { Master.create!(whatever: 42) }
    let!(:slave1_1) { Slave.create!(master: master1, whatever: :foo) }
    let!(:slave1_2) { Slave.create!(master: master1, whatever: :bar) }
    let!(:slave1_3) { Slave.create!(master: master1, whatever: :baz) }

    context 'standard transactions' do
      let!(:targets) { [master1, slave1_1] }

      it 'commit on no error' do
        value = Master.transaction { update_whatevers(*targets) }
        expect(check_whatevers(value, *targets)).to be true
      end

      context 'rollback on ActiveRecord::Rollback' do
        before do
          Master.transaction do
            update_whatevers(*targets)
            raise ActiveRecord::Rollback
          end
        end

        it { expect(master1.reload.whatever).to eq('42') }
        it { expect(slave1_1.reload.whatever).to eq('foo') }
      end

      context 'rollback on RuntimeError' do
        before do
          Master.transaction do
            update_whatevers(*targets)
            raise 'Fcuk!'
          end rescue ActiveRecord::Base.logger.try(:info, "Rescued: #{$!.message}")
        end

        it { expect(master1.reload.whatever).to eq('42') }
        it { expect(slave1_1.reload.whatever).to eq('foo') }
      end
    end

  ##############################################################################

    context 'guarded transactions' do
      let!(:targets) { [master1, slave1_1] }

      before { Transdeal.configure(&configurator) }

      it 'commit on no error' do
        value = Transdeal.transdeal(master1) { update_whatevers(*targets) }
        expect(check_whatevers(value, *targets)).to be true
      end

      context 'rollback on ActiveRecord::Rollback' do
        let(:value) do
          Transdeal.transdeal(master1) do
            update_whatevers(*targets)
            raise ActiveRecord::Rollback
          end
        end

        it 'calls back the tuned backend' do
          expect { value }.to output(/whatever:/).to_stdout
          expect(master1.reload.whatever).to eq('42')
          expect(slave1_1.reload.whatever).to eq('foo')
        end
      end

      context 'rollback on RuntimeError' do
        let(:value) do
          Transdeal.transdeal(master1) do
            update_whatevers(*targets)
            raise 'Fcuk!'
          end rescue ActiveRecord::Base.logger.try(:info, "Rescued: #{$!.message}")
        end

        it 'calls back the tuned backend' do
          expect { value }.to output(/whatever:/).to_stdout
          expect(master1.reload.whatever).to eq('42')
          expect(slave1_1.reload.whatever).to eq('foo')
        end
      end

      context 'rollback with explicit handler' do
        let(:value) do
          Transdeal.transaction(master1, callback: :callback_handler) do
            update_whatevers(*targets)
            raise ActiveRecord::Rollback
          end
        end

        it 'calls back the tuned backend' do
          expect { value }.to output(/(whatever:.*?){2}/m).to_stdout
          expect(master1.reload.whatever).to eq('42')
          expect(slave1_1.reload.whatever).to eq('foo')
        end
      end
    end
  end
end
