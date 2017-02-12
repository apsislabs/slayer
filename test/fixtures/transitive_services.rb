class AService < Slayer::Service
  def self.return_5; 5; end

  def return_3; 3; end
end

class BService < Slayer::Service
  dependencies AService

  def self.return_10; AService.return_5 * 2;     end
  def return_6;       AService.new.return_3 * 2; end
  def return_15;      AService.return_5 * 3;     end
end

class CService < Slayer::Service
  dependencies BService

  def self.return_11; BService.return_10 + 1;    end
  def self.return_8;  BService.new.return_6 + 2; end
  def return_7;       BService.new.return_6 + 1; end
end
