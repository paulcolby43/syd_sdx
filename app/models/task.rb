class Task
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.containers(task)
    if task['ContainerXLinks']['MobileDispatchTaskContainerXLinkInformation'].is_a? Hash # Only one result returned, so put it into an array
      return [task['ContainerXLinks']['MobileDispatchTaskContainerXLinkInformation']]
    else
      return task['ContainerXLinks']['MobileDispatchTaskContainerXLinkInformation']
    end
  end
  
end