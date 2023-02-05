require_relative '../parser/ast_printer'
require_relative '../token'
require_relative '../token_type'

RSpec.describe AstPrinter do
  describe "print" do
    subject { described_class.new().print(expression) }

    context "when the expression is literal" do
      let(:expression) { Literal.new("taco") }

      it "just prints the thing" do
        expect(subject).to eq("taco")
      end

      context "when the literal is nil" do
        let(:expression) { Literal.new(nil) }

        it "just prints the nil" do
          expect(subject).to eq("nil")
        end
      end
    end

    context "when given a mix of expressions" do
      let(:expression) { Binary.new(left, operator, right) }
      let(:left) { Unary.new(Token.new(TokenType::MINUS, "-", nil, 1), Literal.new(12)) }
      let(:operator) { Token.new(TokenType::STAR, "*", nil, 1) }
      let(:right) { Grouping.new(Literal.new(45.12)) }

      it "prints what it should" do
        expect{ subject }.to output(a_string_including('"(* (- 12) (group 45.12))"')).to_stdout
      end
    end
  end
end
