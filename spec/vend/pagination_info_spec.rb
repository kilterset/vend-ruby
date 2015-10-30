require 'spec_helper'

describe Vend::PaginationInfo do

  subject { described_class.new(response) }

  let(:response)  { double("response") }

  specify :response do
    expect(subject.response).to eq response
  end

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

    specify :pages do
      expect(subject.pages).to eq 75
    end

    specify :page do
      expect(subject.page).to eq 41
    end

    specify :paged do
      expect(subject).to be_paged
    end

    describe "#last_page?" do
      specify :is_not_last_page do
        expect(subject).to_not be_last_page
      end

      context "when page is equal to pages" do
        before do
          subject.stub(page: 42, pages: 42)
        end

        specify :is_last_page do
          expect(subject).to be_last_page
        end
      end

    end
  end

  context "when response does not have pagination info" do
    let(:response)  { Hash.new }
    specify :pages do
      expect(subject.pages).to eq 1
    end

    specify :page do
      expect(subject.page).to eq 1
    end

    specify :is_last_page do
      expect(subject).to be_last_page
    end

    specify :is_paged do
      expect(subject).to_not be_paged
    end
  end
end
