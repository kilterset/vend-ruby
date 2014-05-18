require 'spec_helper'

describe Vend::PaginationInfo do

  subject { described_class.new(response) }

  let(:response)  { double("response") }

  its(:response)  { should == response }

  context "when response has pagination info" do
    let(:response)  {
      {
        "pagination" => {
          "results"   => 7461,
          "page"      => 41,
          "page_size" => 100,
          "pages"     => 75 
        }
      }
    }

    its(:pages) { should == 75 }
    its(:page)  { should == 41 }
    it { should be_paged }

    describe "#last_page?" do

      it { should_not be_last_page }

      context "when page is equal to pages" do
        before do
          subject.stub(:page => 42, :pages => 42)
        end
        it { should be_last_page }
      end

    end
  end

  context "when response does not have pagination info" do
    let(:response)  { Hash.new }
    its(:pages) { should == 1 }
    its(:page)  { should == 1 }
    it { should be_last_page }
    it { should_not be_paged }
  end
end
