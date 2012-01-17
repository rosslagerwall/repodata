module Repodata
  class JobQueue
    def initialize(&code)
      @task_queue = Queue.new
      @threads = []
      @threads << Thread.new do
        loop {
          item = @task_queue.pop
          if item.nil?
            @task_queue << nil
            break
          else
            code.call(item)
          end
        }
      end
    end

    def <<(item)
      @task_queue << item
    end

    def finish
      @task_queue << nil
    end

    def wait
      @threads.each { |thread| thread.join }
    end
  end
end
