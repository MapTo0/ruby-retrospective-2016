RSpec.describe 'Version' do
  describe 'Version' do
    context 'initialization' do
      it 'creates a basic Version' do
        expect(Version.new("1")).to be_a Version
      end

      it 'creates a valid Version' do
        valid_options = ["1", "1.1.1", "1.1.1.1", Version.new("1")]
        valid_options.each do |version|
          expect(Version.new(version)).to be_truthy
        end
      end

      it 'creates an invalid Version' do
        invalid_options = [
          "asd", :sym, "1,1", "-1", "-1.1", "1..1", ".1", ".."
        ]
        invalid_options.each do |version|
          expect { Version.new(version) }.to raise_error(ArgumentError)
          expect { Version.new(version) }
          .to raise_error("Invalid version string '#{version}'")
        end
      end

      it 'creates a Version from an empty string or without an argument' do
        expect(Version.new("")).to be_an_instance_of Version
        expect(Version.new).to be_an_instance_of Version
      end
    end

    context 'comparison' do
      it '#>' do
        expect(Version.new("1.1.1")).to be > Version.new("1.1")
        expect(Version.new("1.2")).to be > Version.new("1.1.9")
        expect(Version.new("2.0")).to be > Version.new("1.9")
        expect(Version.new("1.1.9")).to be > Version.new("1.1.8.9")
      end

      it '#<' do
        expect(Version.new("0.1")).to be < Version.new("1")
        expect(Version.new("0.0.1")).to be < Version.new("0.1")
        expect(Version.new("3")).to be < Version.new("3.0.0.0.1")
        expect(Version.new("5")).to be < Version.new("5.5.5")
      end

      it '#<=' do
        expect(Version.new("0.1")).to be <= Version.new("1")
        expect(Version.new("0.0.1")).to be <= Version.new("0.1")
        expect(Version.new("3")).to be <= Version.new("3.0.0.0.1")
        expect(Version.new("1.0")).to be <= Version.new("1")
      end

      it '#>=' do
        expect(Version.new("1.1.1")).to be >= Version.new("1.1")
        expect(Version.new("1.2")).to be >= Version.new("1.1.9")
        expect(Version.new("2.0")).to be >= Version.new("1.9")
        expect(Version.new("1.1.9")).to be >= Version.new("1.1.8.9")
        expect(Version.new("1.0")).to be >= Version.new("1")
      end

      it '#==' do
        expect(Version.new("1.1.0")).to be == Version.new("1.1")
        expect(Version.new("2.0")).to be == Version.new("2")
        expect(Version.new("2.0.0.0.0.0")).to be == Version.new("2")
      end

      it '#<=>' do
        expect(Version.new("1.0.1") <=> Version.new("1.1")).to equal -1
        expect(Version.new("1.2") <=> Version.new("1.1.9")).to equal 1
        expect(Version.new("2.0") <=> Version.new("2")).to equal 0
      end
    end

    context '#to_s' do
      it 'basic versions' do
        expect(Version.new("1.1").to_s).to eq "1.1"
        expect(Version.new("1").to_s).to eq "1"
        expect(Version.new("0").to_s).to eq ""
        expect(Version.new("1.1.1.1.1").to_s).to eq "1.1.1.1.1"
      end

      it 'complex versions' do
        expect(Version.new("1.1.0").to_s).to eq "1.1"
        expect(Version.new("1.0.0").to_s).to eq "1"
        expect(Version.new("0.0").to_s).to eq ""
        expect(Version.new("1.1.1.1.1.0.0.0.0.0.0.0.0.0.0.0").to_s)
        .to eq "1.1.1.1.1"
      end
    end

    context '#components' do
      it 'basic versions' do
        expect(Version.new("1.1").components).to eq [1, 1]
        expect(Version.new("2").components).to eq [2]
        expect(Version.new("2.2").components).to eq [2, 2]
        expect(Version.new("1.2.3.4.5.6.7.8.9").components)
        .to eq [1, 2, 3, 4, 5, 6, 7, 8, 9]
      end

      it 'zero ending versions' do
        expect(Version.new("1.1.0").components).to eq [1, 1]
        expect(Version.new("2.0.0.0.0.0.0").components).to eq [2]
        expect(Version.new("2.0.2.0").components).to eq [2, 0, 2]
      end

      it '#components with a given count' do
        expect(Version.new("1.1.0").components(1)).to eq [1]
        expect(Version.new("1.2.3.4.5.6.7.8").components(4))
        .to match_array [1, 2, 3, 4]
        expect(Version.new("1.2.3.4.5.6.7.8").components(7))
        .to match_array [1, 2, 3, 4, 5, 6, 7]
        expect(Version.new("1.2.3.4.5.6.7.8").components(10))
        .to match_array [1, 2, 3, 4, 5, 6, 7, 8, 0, 0]
        expect(Version.new("1.2").components(5)).to match_array [1, 2, 0, 0, 0]
      end
    end
  end

  describe 'Range' do
    context 'initialization' do
      it 'creates an instance of Range' do
        expect(Range.new(Version.new("1"), "1.9")).to be_a Range
        expect(Range.new("1.1", "1.9")).to be_a Range
        expect(Range.new(Version.new("1"), Version.new("1.9"))).to be_a Range
      end
    end
    context '#include?' do
      it 'checks if argument is >= starting and < ending version' do
        expect(Range.new("1.1", "1.4").include?("1.3")).to be_truthy
        expect(Range.new("1.1", "1.4").include?("1.4")).to be_falsy
        expect(Range.new("1", "2").include?(Version.new("1.5"))).to be_truthy
        expect(Range.new("1", "2").include?("1.5")).to be_truthy
        expect(Range.new("1", "1.1.1").include?("1.1")).to be_truthy
        expect(Range.new("1", "1.1.1").include?("1.1.1")).to be_falsy
        expect(Range.new("2.12", "2.42").include?("2.15")).to be_truthy
      end
    end

    context '#to_a' do
      it 'checls if version are included in an array' do
        expect(Range.new("1.1", "1.2").to_a).to match_array [
          '1.1', '1.1.1', '1.1.2', '1.1.3', '1.1.4', '1.1.5',
          '1.1.6', '1.1.7', '1.1.8', '1.1.9'
        ]
        expect(Range.new("1.1.1", "1.1.5").to_a).to match_array [
          '1.1.1', '1.1.2', '1.1.3', '1.1.4'
        ]
        expect(Range.new("1.9.9", "2.0.2").to_a).to match_array [
          "1.9.9", "2", "2.0.1"
        ]
        expect(Range.new("1.1.0", "1.2.2").to_a).to match_array [
          '1.1', '1.1.1', '1.1.2', '1.1.3', '1.1.4', '1.1.5',
          '1.1.6', '1.1.7', '1.1.8', '1.1.9', '1.2', '1.2.1'
        ]
      end
    end
  end
end