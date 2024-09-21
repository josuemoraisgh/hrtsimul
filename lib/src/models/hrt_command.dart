const Map<int, Map<String, String>> hrtcommand = {
  //Command-Specific Response Codes
  0: {
    '00': 'No Command-Specific Errors',
    '01': 'Undefined',
    '02': 'Invalid Selection (Poll Address)',
    '03': 'Passed Parameter Too Large',
    '04': 'Passed Parameter Too Small',
    '05': 'Too Few Data Bytes Received',
    '06': 'Device-Specific Command Error',
    '07': 'In Write Protect Mode',
    '08':
        'Update Failure | Update In Progress | Set To Nearest Possible Value (Upper or Lower Range Pushed)',
    '09':
        'Invalid Date Code Detected | Lower Range Value Too High | Applied Process Too High | Incorrect Loop Current Mode or Value | Port not Found',
    '0A': 'Lower Range Value Too Low | Applied Process Too Low | Port in Use',
    '0B':
        'Upper Range Value Too High |  Loop Current Not Active (Device in Multidrop Mode) | Trim Error, Excess Correction Attempted | Maximum Ports In Use',
    '0C':
        'Invalid Mode Selection |  Upper Range Value Too Low |  Segment Length Too Small',
    '0D':
        'Upper and Lower Range Values Out Of Limits |  Computation Error, Trim Values Were Not Changed',
    '0E':
        'Span Too Small (Device Accuracy May Be Impaired) | New Lower Range Value Pushed',
    '0F': 'Undefined',
    '10': 'Access Restricted',
    '11':
        'Invalid Device Variable Index. The Device Variable does not exist in this Field Device.',
    '12': 'Invalid Units Code',
    '13': 'Device Variable index not allowed for this command.',
    '14 - 1C': 'Undefined',
    '1D': 'Invalid Span',
    '1E - 1F': 'Undefined',
    '20': 'Busy | A DR Could Not Be Started',
    '21': 'DR Initiated',
    '22': 'DR Running',
    '23': 'DR Dead',
    '24': 'DR Conflict',
    '25 - FF': 'Undefined'
  },
};