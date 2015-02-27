shared_examples_for 'use devisable module' do

  describe "#attempt_set_password" do
    before do 
      @credentials = {password: "vinsol123", password_confirmation: "vinsol123"}
    end 

    it "should update the password" do 
      @employee.attempt_set_password(@credentials)
      @employee.password.should eq("vinsol123")
    end

    it "should_receive update_attributes" do 
      @employee.should_receive(:update_attributes).with(@credentials)
      @employee.attempt_set_password(@credentials)
    end
  end

  describe "#has_no_password?" do 
    context "encrypted_password not present" do 
      it "should return true" do 
        @employee.has_no_password?.should eq(true)
      end
    end

    context "encrypted_password blank" do 
      before do 
        @employee.update_attributes(:encrypted_password => "abcg")
      end

      it "should return false" do 
        @employee.has_no_password?.should eq(false)
      end
    end
  end
  
  describe "#only_if_unconfirmed" do 
    
    context "confirmed" do 
      before do 
        @employee.stub(:confirmed?).and_return(true)
      end

      it "should return false" do 
        @employee.only_if_unconfirmed.should eq(false)
      end

      it "should not yield" do 
        expect{|b| @employee.only_if_unconfirmed(1,&b).not_to yield_control }
      end
    end

    context "not confirmed" do 
      before do 
        @employee.stub(:confirmed?).and_return(false)
      end

      it "should yield" do 
        expect{|b| @employee.only_if_unconfirmed(1,&b).to yield_control }
      end

      it "should return employee" do 
        @employee.only_if_unconfirmed {@employee}.should eq(@employee)
      end
    end
  end

  describe "#password_required?" do 
    context "new record" do 
      before do 
        @employee.stub(:persisted?).and_return(false)
      end

      it "should return false" do 
        @employee.password_required?.should eq(false)
      end
    end

    context "old record" do 
      before do 
        @employee.stub(:persisted?).and_return(true)
      end

      context "password is nil but not password_confirmation" do 
        before do 
          @employee.stub(:password).and_return(nil)
          @employee.stub(:password_confirmation).and_return("pass")
        end

        it "should return true" do 
          @employee.password_required?.should eq(true)
        end 
      end

      context "password_confirmation is nil but not password" do 
        before do 
          @employee.stub(:password_confirmation).and_return(nil)
          @employee.stub(:password).and_return("pass")
        end

        it "should return true" do 
          @employee.password_required?.should eq(true)
        end 
      end

      context "password_confirmation and password both are nil" do 
        before do 
          @employee.stub(:password_confirmation).and_return(nil)
          @employee.stub(:password).and_return(nil)
        end

        it "should return false" do 
          @employee.password_required?.should eq(false)
        end 
      end

      context "password is not nil and not even password_confirmation" do 
        before do 
          @employee.stub(:password).and_return("pass")
          @employee.stub(:password_confirmation).and_return("pass")
        end

        it "should return false" do 
          @employee.password_required?.should eq(true)
        end 
      end
    end
  end
  describe "#active_for_authentication?" do 
    context "employee has no roles" do 
      before do 
        @employee.stub(:has_any_role?).and_return(false)
      end

      it "should return false" do 
        @employee.active_for_authentication?.should eq(false)
      end
    end

    context "employee has role" do 
      context "super_admin" do 
        before do 
          @employee.stub(:has_role?).with(:super_admin).and_return(true)
        end

        context "super returns false" do 
          before do 
            Employee.any_instance.stub(:active_for_authentication?).and_return(false)
          end
          
          it "should return false" do 
            @employee.active_for_authentication?.should eq(false)
          end
        end

        context "super returns true" do
          before do 
            Employee.any_instance.stub(:active_for_authentication?).and_return(true)
          end

          it "should return true" do 
            @employee.active_for_authentication?.should eq(true)
          end
        end
      end

      context "other admin or employee" do 
        context "employee company is disabled" do 
          before do 
            @employee.stub(:company).and_return(@company)
            @company.stub(:enabled?).and_return(false)
          end

          it "should return false" do 
            @employee.active_for_authentication?.should eq(false)
          end
        end

        context "employee company is enabled" do 
          before do 
            Employee.any_instance.stub(:active_for_authentication?).and_return(false)
          end

          context "super returns false" do 
            it "should return false" do 
              @employee.active_for_authentication?.should eq(false)
            end
          end

          context "super returns true" do
            before do 
              Employee.any_instance.stub(:active_for_authentication?).and_return(true)
            end

            it "should return true" do 
              @employee.active_for_authentication?.should eq(true)
            end
          end
        end
      end
    end
  end
  
  describe "#inactive_message" do 
    context "employee has no roles" do 
      before do  
        @employee.stub(:has_any_role?).and_return(false)
      end

      it "should return error message" do 
        @employee.inactive_message.should eq("Your account has been disabled")
      end
    end

    context "employee is admin" do 
      before do 
        @employee.stub(:has_any_role?).and_return(true)
        @employee.stub(:company).and_return(@company)
      end

      context "company is enabled" do 
        before do 
          @company.stub(:enabled?).and_return(true)
        end

        it "should return super" do 
          @employee.inactive_message.should eq(:unconfirmed)
        end
      end

      context "company is disabled" do 
        before do 
          @company.stub(:enabled?).and_return(false)
        end

        it "should return deactivated" do 
          @employee.inactive_message.should eq(:deactivated)
        end
      end
    end
  end
end