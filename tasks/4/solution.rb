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
      it 'assumes unspecified components are zero' do
        expect(Version.new('3.0.0.0.0')).to eq Version.new('3')
        expect(Version.new('3.0.0.0.0')).to eq Version.new('3.0.0')
        expect(Version.new('3.4')      ).to eq Version.new('3.4.0')
        expect(Version.new('3.4')      ).to be < Version.new('3.4.1')
        expect(Version.new('3.43.1')   ).to be < Version.new('3.43.1.1')
      end

      it 'compares simple inequalities' do
        expect(Version.new('1')    ).to be > Version.new('0')
        expect(Version.new('0.1')  ).to be > Version.new('0')
        expect(Version.new('0.0.1')).to be > Version.new('0')
        expect(Version.new('0')    ).to_not be > Version.new('0.0.1')

        expect(Version.new('1')    ).to be < Version.new('1.0.1')
        expect(Version.new('1.1')  ).to be < Version.new('1.1.1')
        expect(Version.new('11.3') ).to be < Version.new('11.3.1')
        expect(Version.new('1.0.1')).to_not be < Version.new('1')

        expect(Version.new('1.23')).to be > Version.new('1.22')
        expect(Version.new('1.23')).to be > Version.new('1.4')

        expect(Version.new('1.23.3')).to be > Version.new('1.4.8')
        expect(Version.new('1.22.3')).to be < Version.new('1.23.2')

        expect(Version.new('1.22.0.3')).to be < Version.new('1.23.0.2')
        expect(Version.new('2.22.0.3')).to be > Version.new('1.23.0.2')
      end

      it 'implements <= and >=' do
        expect(Version.new('1.23')).to be >= Version.new('1.22')
        expect(Version.new('1.23')).to be >= Version.new('1.23')
        expect(Version.new('1.23')).to_not be >= Version.new('1.24')
        expect(Version.new('1.23')).to be <= Version.new('1.24')
        expect(Version.new('1.23')).to be <= Version.new('1.23')
        expect(Version.new('1.23')).to_not be <= Version.new('1.21')
      end

      it '#>' do
        expect(Version.new('1')    ).to be > Version.new('0')
        expect(Version.new('0.1')  ).to be > Version.new('0')
        expect(Version.new('0.0.1')).to be > Version.new('0')
        expect(Version.new('0')    ).to_not be > Version.new('0.0.1')
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

      it 'cuts the number of components if they need to be fewer' do
        expect(Version.new('0.1.2.3.4.0').components(4)).to eq [0, 1, 2, 3]
      end

      it 'is not able to modify the internal data of the version' do
        version = Version.new('1.2.3')
        version.components << 4

        expect(version).to eq Version.new('1.2.3')
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

      it 'accepts versions as strings' do
        range = Version::Range.new('1.1.1', '3.3.3')
        expect(range).to include Version.new('1.99')
        expect(range).to_not include Version.new('22')
      end
    end
    context '#include?' do
      let(:lower_version) { Version.new('1.1.11') }
      let(:higher_version) { Version.new('3.1.12') }
      let(:range) { Version::Range.new(lower_version, higher_version) }

      it 'checks if argument is >= starting and < ending version' do
        expect(Range.new("1.1", "1.4").include?("1.3")).to be_truthy
        expect(Range.new("1", "1.1.1").include?("1.1.1")).to be_falsy
        expect(Range.new("2.12", "2.42").include?("2.15")).to be_truthy
      end

      it 'can tell if a version is included in the range' do
        expect(range).to_not include Version.new('3.1.15')
        expect(range).to_not include Version.new('3.2.0')
        expect(range).to_not include Version.new('0.1')
        expect(range).to_not include Version.new('1.1.10')
        expect(range).to_not include Version.new('20.1.10')
      end

      it 'includes the first version in the range' do
        expect(range).to include Version.new('1.1.11')
      end

      it 'excludes the last version from the range' do
        expect(range).to_not include Version.new('3.1.12')
      end

      it 'can be given a string' do
        expect(range).to include '1.1.12'
        expect(range).to_not include '3.1.15'
      end
    end

    context '#to_a' do
      it 'checls if version are included in an array' do
        expect(Range.new("1.1.1", "1.1.5").to_a).to match_array [
          '1.1.1', '1.1.2', '1.1.3', '1.1.4', '1.1.5'
        ]
        expect(Range.new("1.9.9", "2.0.2").to_a).to match_array [
          "1.9.9", "2.0.0", "2.0.1", "2.0.2"
        ]
        expect(Range.new("1.1.0", "1.2.2").to_a).to match_array [
          '1.1.0', '1.1.1', '1.1.2', '1.1.3', '1.1.4', '1.1.5',
          '1.1.6', '1.1.7', '1.1.8', '1.1.9', '1.2.0', '1.2.1', '1.2.2'
        ]
      end

      it 'can iterate more complex versions' do
        range = Version::Range.new('1.1.2', '1.3')

        expect(range.to_a.map(&:to_s)).to match_array [
          '1.1.2', '1.1.3', '1.1.4', '1.1.5', '1.1.6', '1.1.7', '1.1.8',
          '1.1.9',
          '1.2', '1.2.1', '1.2.2', '1.2.3', '1.2.4', '1.2.5', '1.2.6', '1.2.7',
          '1.2.8', '1.2.9'
        ]
      end
    end
  end
end