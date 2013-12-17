%load phidget library for current OS
loadphidget21;

pause on;

%Handle for Stepper Motor
stepperHandle = libpointer('int32Ptr');

%Create Phidget Stepper Handle
calllib('phidget21', 'CPhidgetStepper_create', stepperHandle);

%Open Phidget device with any serial number
calllib('phidget21', 'CPhidget_open', stepperHandle, -1);

if calllib('phidget21', 'CPhidget_waitForAttachment', stepperHandle, 10000) == 0
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
    
    %Pointer for Stepper Motor current position
    stepperPosition = libpointer('int64Ptr', 0);
    
    %Stepper Motor Target Position
    targetPosition = 2100;
    
    %Engage the Stepper Motor
    calllib('phidget21', 'CPhidgetStepper_setEngaged', stepperHandle, 0, 1);
    
    %Create AudioRecorder obj to record audio from device
    recorder = dsp.AudioRecorder('DeviceName', 'Line In (Scarlett 2i2 USB)', 'SampleRate', 44100, 'NumChannels', 1, 'DeviceDataType', '32-bit float', 'BufferSizeSource', 'Property', 'BufferSize', 4096, 'SamplesPerFrame', 4096, 'OutputDataType', 'double');
    %Create MatFileWriter obj to record captured audio data
    matWriter = dsp.MatFileWriter('Filename', 'recording.mat', 'VariableName', 'audioData', 'FrameBasedProcessing', true);
    
    %Notify recording status
    disp('Recording Begins');
    
    while get(stepperPosition, 'Value') <= targetPosition;
        
        %Update Stepper Motor Position
        calllib('phidget21', 'CPhidgetStepper_getCurrentPosition', stepperHandle, 0, stepperPosition);        
        if get(stepperPosition, 'Value') >= targetPosition
            calllib('phidget21', 'CPhidgetStepper_setTargetPosition', stepperHandle, 0, stepperPosition.Value);
        else
            calllib('phidget21', 'CPhidgetStepper_setTargetPosition', stepperHandle, 0, stepperPosition.Value+100);
        end
        %pause(0.001);
        
        %Record audio data
        step(matWriter, step(recorder));
        
    end
    
    %Notify recording status
    disp('Recording Ends');
    
    release(recorder);
    release(matWriter);
    
    %Disengage the Stepper Motor
    calllib('phidget21', 'CPhidgetStepper_setEngaged', stepperHandle, 0, 0);
    
    disp('Stepper Motor Control Disengaged');
    
    %Close the Phidget Handle
    calllib('phidget21', 'CPhidget_close', stepperHandle);
    
    %Free the Phidget Handle
    calllib('phidget21', 'CPhidget_delete', stepperHandle);
    
else
    disp('Failed to attach to Phidget Device');
    disp('Exit');
    
end