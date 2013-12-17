function stepperControl
    
    %load phidget library for current OS
    loadphidget21;
    
    pause on;
    
    %Handle for Stepper Motor
    stepperHandle = libpointer('int32Ptr');
    
    %Create Phidget Stepper Handle
    calllib('phidget21', 'CPhidgetStepper_create', stepperHandle);
    
    %Open Phidget device with any serial number
    calllib('phidget21', 'CPhidget_open', stepperHandle, -1);
    
    %Wait 10 seconds until Phidget attachment
    if calllib('phidget21', 'CPhidget_waitForAttachment', stepperHandle, 10000) == 0
        disp('Phidget Successfully Attached');
        
        %Pointer for device serial number
        stepperSerial = libpointer('int32Ptr', 0);
        
        %Pointer for device minimum current
        stepperMinCurrent = libpointer('doublePtr', 0);
        
        %Pointer for device maximum current
        stepperMaxCurrent = libpointer('doublePtr', 0);
        
        %Pointer for device minimum velocity 
        stepperMinV = libpointer('doublePtr', 0);
        
        %Pointer for device maximum velocity
        stepperMaxV = libpointer('doublePtr', 0);
        
        %Pointer for device minimum acceleration
        stepperMinAccel = libpointer('doublePtr', 0);
        
        %Pointer for device maximum acceleration
        stepperMaxAccel = libpointer('doublePtr', 0);
        
        %Get the Phidget device serial number into ptr
        calllib('phidget21', 'CPhidget_getSerialNumber', stepperHandle, stepperSerial);
        
        %Get the Phidget device minimum current into ptr
        calllib('phidget21', 'CPhidgetStepper_getCurrentMin', stepperHandle, 0, stepperMinCurrent);
        
        %Get the Phidget device maximum current into ptr
        calllib('phidget21', 'CPhidgetStepper_getCurrentMax', stepperHandle, 0, stepperMaxCurrent);
        
        %Get the Stepper Motor minimum velocity into ptr
        calllib('phidget21', 'CPhidgetStepper_getVelocityMin', stepperHandle, 0, stepperMinV);
        
        %Get the Stepper Motor maximum velocity into ptr
        calllib('phidget21', 'CPhidgetStepper_getVelocityMax', stepperHandle, 0, stepperMaxV);
        
        %Get the Stepper Motor minimum acceleration into ptr
        calllib('phidget21', 'CPhidgetStepper_getAccelerationMin', stepperHandle, 0, stepperMinAccel);
        
        %Get the Stepper Motor maximum acceleration into ptr
        calllib('phidget21', 'CPhidgetStepper_getAccelerationMax', stepperHandle, 0, stepperMaxAccel);
        
        phidgetInfo = sprintf('Stepper Motor Serial Number: %d\nStepper Motor Minimum Current: %f\nStepper Motor Maximum Current: %f\nStepper Motor Minimum Velocity: %f\nStepper Motor Maximum Velocity: %f\nStepper Motor Minimum Acceleration: %f\nStepper Motor Maximum Acceleration: %f\n', stepperSerial.Value, stepperMinCurrent.Value, stepperMaxCurrent.Value, stepperMinV.Value, stepperMaxV.Value, stepperMinAccel.Value, stepperMaxAccel.Value);
        
        %Display Phidget Device Specs & Property
        disp(phidgetInfo);
        
        %Set the Stepper Motor velocity limit
        calllib('phidget21', 'CPhidgetStepper_setVelocityLimit', stepperHandle, 0, 4000);
        
        %Set the Stepper Motor acceleration
        calllib('phidget21', 'CPhidgetStepper_setAcceleration', stepperHandle, 0, 4000);
        
        %Set the Stepper Motor current limit
        calllib('phidget21', 'CPhidgetStepper_setCurrentLimit', stepperHandle, 0, 0.26);
        
        disp('Move Stepper Motor to Position 0, Press Any Key to Continue');
        
        %Wait until Stepper Motor in place
        pause;
        
        %Set current position to position 0
        calllib('phidget21', 'CPhidgetStepper_setCurrentPosition', stepperHandle, 0, 0);
        
        %Engage the Stepper Motor
        calllib('phidget21', 'CPhidgetStepper_setEngaged', stepperHandle, 0, 1);
             
        %Boolean variable for Stepper Motor control, 0 = False, 1 = True
        control = libpointer('int32Ptr', 1);
        
        %Pointer for Stepper Motor movement, 0 = Static, 1 = Left, 2 =
        %Right, 3 = Idle
        stepperMovement = libpointer('int32Ptr', 0);
        
        %Pointer for Stepper Motor current position
        stepperPosition = libpointer('int64Ptr', 0);
        
        %Get the Stepper Motor current position
        %calllib('phidget21', 'CPhidgetStepper_getCurrentPosition', stepperHandle, 0, stepperCurrentPos);
        
        %Setup function handle callback for KeyPressedCallbck
        mDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
        cmdWnd = mDesktop.getClient('Command Window');
        cmdWndView = cmdWnd.getComponent(0).getViewport.getComponent(0);
        h_cw = handle(cmdWndView,'CallbackProperties');
        set(h_cw, 'KeyPressedCallback', {@controlStepper, stepperHandle, stepperMovement ,control});
        
        disp('Stepper Motor Control Engaged');        
                
        while get(control, 'Value') == 1            
            calllib('phidget21', 'CPhidgetStepper_getCurrentPosition', stepperHandle, 0, stepperPosition);
            if get(stepperMovement, 'Value') == 0
               calllib('phidget21', 'CPhidgetStepper_setTargetPosition', stepperHandle, 0, stepperPosition.Value);
            elseif get(stepperMovement, 'Value') == 1
               calllib('phidget21', 'CPhidgetStepper_setTargetPosition', stepperHandle, 0, stepperPosition.Value-1000);
            elseif get(stepperMovement, 'Value') == 2
               calllib('phidget21', 'CPhidgetStepper_setTargetPosition', stepperHandle, 0, stepperPosition.Value+1000);
            else
                
            end
            pause(0.001);
        end   
        
        %Total Steps between Boundaries: 2180
                
        %Reset function handle callback for KeyPressedCallbck
        set(h_cw, 'KeyPressedCallback', '');
                   
        %Disengage the Stepper Motor
        calllib('phidget21', 'CPhidgetStepper_setEngaged', stepperHandle, 0, 0);
    
        disp('Stepper Motor Control Disengaged');
        
        %Close the Phidget Handle
        calllib('phidget21', 'CPhidget_close', stepperHandle);
    
        %Free the Phidget Handle
        calllib('phidget21', 'CPhidget_delete', stepperHandle);
        
    else
        disp('Failed to attach to Phidget Device');
    end   
    
    pause off
    
end

function controlStepper (src, eventdata, phid, direction, state)    
    if get(eventdata, 'KeyCode') == 37 %leftarrow
        disp('Moving Left');
        set(direction, 'Value', 1);
    elseif get(eventdata, 'KeyCode') == 39 %rightarrow
        disp('Moving Right');
        set(direction, 'Value', 2);
    elseif get(eventdata, 'KeyCode') == 32 %spacebar
        disp('Stop');
        set(direction, 'Value', 0);
    elseif get(eventdata, 'KeyCode') == 80 %p
        valPtr = libpointer('int64Ptr', 0);
        calllib('phidget21', 'CPhidgetStepper_getCurrentPosition', phid, 0, valPtr);
        curPos = get(valPtr, 'Value');
        info = sprintf('Stepper Motor Position: %d', curPos);
        disp(info);
    else
       disp('Exit Control');
       set(state, 'Value', 0);  
    end
end