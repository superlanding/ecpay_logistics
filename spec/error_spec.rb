require 'spec_helper'

RSpec.describe ECpayErrorDefinition do
  describe 'error classes' do
    it 'defines ECpayError as base error class' do
      expect(ECpayErrorDefinition::ECpayError).to be < StandardError
    end

    it 'defines ECpayMissingOption that inherits from ECpayError' do
      expect(ECpayErrorDefinition::ECpayMissingOption).to be < ECpayErrorDefinition::ECpayError
    end

    it 'defines ECpayInvalidMode that inherits from ECpayError' do
      expect(ECpayErrorDefinition::ECpayInvalidMode).to be < ECpayErrorDefinition::ECpayError
    end

    it 'defines ECpayInvalidParam that inherits from ECpayError' do
      expect(ECpayErrorDefinition::ECpayInvalidParam).to be < ECpayErrorDefinition::ECpayError
    end

    it 'defines ECpayLogisticsRuleViolate that inherits from ECpayError' do
      expect(ECpayErrorDefinition::ECpayLogisticsRuleViolate).to be < ECpayErrorDefinition::ECpayError
    end

    it 'can raise ECpayError with message' do
      expect { raise ECpayErrorDefinition::ECpayError, "Test error" }
        .to raise_error(ECpayErrorDefinition::ECpayError, "Test error")
    end

    it 'can raise ECpayMissingOption with message' do
      expect { raise ECpayErrorDefinition::ECpayMissingOption, "Missing required option" }
        .to raise_error(ECpayErrorDefinition::ECpayMissingOption, "Missing required option")
    end

    it 'can raise ECpayInvalidMode with message' do
      expect { raise ECpayErrorDefinition::ECpayInvalidMode, "Invalid operation mode" }
        .to raise_error(ECpayErrorDefinition::ECpayInvalidMode, "Invalid operation mode")
    end

    it 'can raise ECpayInvalidParam with message' do
      expect { raise ECpayErrorDefinition::ECpayInvalidParam, "Invalid parameter" }
        .to raise_error(ECpayErrorDefinition::ECpayInvalidParam, "Invalid parameter")
    end

    it 'can raise ECpayLogisticsRuleViolate with message' do
      expect { raise ECpayErrorDefinition::ECpayLogisticsRuleViolate, "Rule violation" }
        .to raise_error(ECpayErrorDefinition::ECpayLogisticsRuleViolate, "Rule violation")
    end

    it 'can catch ECpayError subclasses as ECpayError' do
      expect { raise ECpayErrorDefinition::ECpayInvalidParam, "Test" }
        .to raise_error(ECpayErrorDefinition::ECpayError)
    end
  end
end
