#$Source: /home/bbennett/pass/archive/Posda/tpl/iodcomp/dx.tpl,v $
#$Date: 2010/04/30 18:53:52 $
#$Revision: 1.2 $
#
CompositeIOD="DXImageForProcessing"			Condition="DXImageForProcessingInstance"
	InformationEntity="File"
		Module="FileMetaInformation"		Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"					Usage="M"
		Module="ClinicalTrialSubject"		Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"				Usage="M"
		Module="PatientStudy"				Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"			Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"				Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
		Module="DXSeries"					Usage="M"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="U"	Condition="NeedModuleFrameOfReference"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="ContrastBolus"				Usage="U"	Condition="NeedModuleContrastBolus"
		Module="DisplayShutter"				Usage="U"	Condition="NeedModuleDisplayShutter"
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Intervention"				Usage="U"	Condition="NeedModuleIntervention"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="DXAnatomyImaged"			Usage="M"
		Module="DXImage"					Usage="M"
		Module="DXDetector"					Usage="M"
		Module="XRayCollimator"				Usage="U"	Condition="NeedModuleXRayCollimator"
		Module="DXPositioning"				Usage="U"	Condition="NeedModuleDXPositioning"
		Module="XRayTomographyAcquisition"	Usage="U"	Condition="NeedToCheckModuleXRayTomographyAcquisition"
		Module="XRayAcquisitionDose"		Usage="U"	Condition="NeedModuleXRayAcquisitionDose"
		Module="XRayGeneration"				Usage="U"	Condition="NeedModuleXRayGeneration"
		Module="XRayFiltration"				Usage="U"	Condition="NeedModuleXRayFiltration"
		Module="XRayGrid"					Usage="U"	Condition="NeedModuleXRayGrid"
		Module="OverlayPlane"				Usage="C"	Condition="NeedModuleOverlayPlane"
		Module="VOILUT"						Usage="C"	Condition="DXNeedModuleVOILUT"
		Module="ImageHistogram"				Usage="U"	Condition="NeedModuleImageHistogram"
		Module="AcquisitionContext"			Usage="M"
		Module="SOPCommon"					Usage="M"
		Module="CheckSingleFramePseudo"		Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="DXImageForPresentation"			Condition="DXImageForPresentationInstance"
	InformationEntity="File"
		Module="FileMetaInformation"		Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"					Usage="M"
		Module="ClinicalTrialSubject"		Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"				Usage="M"
		Module="PatientStudy"				Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"			Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"				Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
		Module="DXSeries"					Usage="M"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="U"	Condition="NeedModuleFrameOfReference"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="ContrastBolus"				Usage="U"	Condition="NeedModuleContrastBolus"
		Module="DisplayShutter"				Usage="U"	Condition="NeedModuleDisplayShutter"
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Intervention"				Usage="U"	Condition="NeedModuleIntervention"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="DXAnatomyImaged"			Usage="M"
		Module="DXImage"					Usage="M"
		Module="DXDetector"					Usage="M"
		Module="XRayCollimator"				Usage="U"	Condition="NeedModuleXRayCollimator"
		Module="DXPositioning"				Usage="U"	Condition="NeedModuleDXPositioning"
		Module="XRayTomographyAcquisition"	Usage="U"	Condition="NeedToCheckModuleXRayTomographyAcquisition"
		Module="XRayAcquisitionDose"		Usage="U"	Condition="NeedModuleXRayAcquisitionDose"
		Module="XRayGeneration"				Usage="U"	Condition="NeedModuleXRayGeneration"
		Module="XRayFiltration"				Usage="U"	Condition="NeedModuleXRayFiltration"
		Module="XRayGrid"					Usage="U"	Condition="NeedModuleXRayGrid"
		Module="OverlayPlane"				Usage="C"	Condition="NeedModuleOverlayPlane"
		Module="VOILUT"						Usage="C"	Condition="DXNeedModuleVOILUT"
		Module="ImageHistogram"				Usage="U"	Condition="NeedModuleImageHistogram"
		Module="AcquisitionContext"			Usage="M"
		Module="SOPCommon"					Usage="M"
		Module="CheckSingleFramePseudo"		Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="MammographyImageForProcessing"			Condition="MammographyImageForProcessingInstance"
	InformationEntity="File"
		Module="FileMetaInformation"		Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"					Usage="M"
		Module="ClinicalTrialSubject"		Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"				Usage="M"
		Module="PatientStudy"				Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"			Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"				Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
		Module="DXSeries"					Usage="M"
		Module="MammographySeries"			Usage="M"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="U"	Condition="NeedModuleFrameOfReference"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="ContrastBolus"				Usage="U"	Condition="NeedModuleContrastBolus"
		Module="DisplayShutter"				Usage="U"	Condition="NeedModuleDisplayShutter"
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Intervention"				Usage="U"	Condition="NeedModuleIntervention"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="DXAnatomyImaged"			Usage="M"
		Module="DXImage"					Usage="M"
		Module="DXDetector"					Usage="M"
		Module="XRayCollimator"				Usage="U"	Condition="NeedModuleXRayCollimator"
		Module="DXPositioning"				Usage="U"	Condition="NeedModuleDXPositioning"
		Module="XRayTomographyAcquisition"	Usage="U"	Condition="NeedToCheckModuleXRayTomographyAcquisition"
		Module="XRayAcquisitionDose"		Usage="U"	Condition="NeedModuleXRayAcquisitionDose"
		Module="XRayGeneration"				Usage="U"	Condition="NeedModuleXRayGeneration"
		Module="XRayFiltration"				Usage="U"	Condition="NeedModuleXRayFiltration"
		Module="XRayGrid"					Usage="U"	Condition="NeedModuleXRayGrid"
		Module="MammographyImage"			Usage="M"
		Module="OverlayPlane"				Usage="C"	Condition="NeedModuleOverlayPlane"
		Module="VOILUT"						Usage="C"	Condition="DXNeedModuleVOILUT"
		Module="ImageHistogram"				Usage="U"	Condition="NeedModuleImageHistogram"
		Module="AcquisitionContext"			Usage="M"
		Module="SOPCommon"					Usage="M"
		Module="CheckSingleFramePseudo"		Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="MammographyImageForPresentation"			Condition="MammographyImageForPresentationInstance"
	InformationEntity="File"
		Module="FileMetaInformation"		Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"					Usage="M"
		Module="ClinicalTrialSubject"		Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"				Usage="M"
		Module="PatientStudy"				Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"			Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"				Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
		Module="DXSeries"					Usage="M"
		Module="MammographySeries"			Usage="M"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="U"	Condition="NeedModuleFrameOfReference"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="ContrastBolus"				Usage="U"	Condition="NeedModuleContrastBolus"
		Module="DisplayShutter"				Usage="U"	Condition="NeedModuleDisplayShutter"
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Intervention"				Usage="U"	Condition="NeedModuleIntervention"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="DXAnatomyImaged"			Usage="M"
		Module="DXImage"					Usage="M"
		Module="DXDetector"					Usage="M"
		Module="XRayCollimator"				Usage="U"	Condition="NeedModuleXRayCollimator"
		Module="DXPositioning"				Usage="U"	Condition="NeedModuleDXPositioning"
		Module="XRayTomographyAcquisition"	Usage="U"	Condition="NeedToCheckModuleXRayTomographyAcquisition"
		Module="XRayAcquisitionDose"		Usage="U"	Condition="NeedModuleXRayAcquisitionDose"
		Module="XRayGeneration"				Usage="U"	Condition="NeedModuleXRayGeneration"
		Module="XRayFiltration"				Usage="U"	Condition="NeedModuleXRayFiltration"
		Module="XRayGrid"					Usage="U"	Condition="NeedModuleXRayGrid"
		Module="MammographyImage"			Usage="M"
		Module="OverlayPlane"				Usage="C"	Condition="NeedModuleOverlayPlane"
		Module="VOILUT"						Usage="C"	Condition="DXNeedModuleVOILUT"
		Module="ImageHistogram"				Usage="U"	Condition="NeedModuleImageHistogram"
		Module="AcquisitionContext"			Usage="M"
		Module="SOPCommon"					Usage="M"
		Module="CheckSingleFramePseudo"		Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="MammographyImageForProcessingIHEMammo"			Condition="MammographyImageForProcessingInstance"	Profile="IHEMammo"
	InformationEntity="File"
		Module="FileMetaInformation"		Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"					Usage="M"
		Module="ClinicalTrialSubject"		Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"				Usage="M"
		Module="PatientStudy"				Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"			Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"				Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
		Module="DXSeries"					Usage="M"
		Module="MammographySeries"			Usage="M"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="U"	Condition="NeedModuleFrameOfReference"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="ContrastBolus"				Usage="U"	Condition="NeedModuleContrastBolus"
		Module="DisplayShutter"				Usage="U"	Condition="NeedModuleDisplayShutter"
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Intervention"				Usage="U"	Condition="NeedModuleIntervention"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="DXAnatomyImaged"			Usage="M"
		Module="DXImage"					Usage="M"
		Module="DXDetector"					Usage="M"
		Module="XRayCollimator"				Usage="U"	Condition="NeedModuleXRayCollimator"
		Module="DXPositioning"				Usage="U"	Condition="NeedModuleDXPositioning"
		Module="XRayTomographyAcquisition"	Usage="U"	Condition="NeedToCheckModuleXRayTomographyAcquisition"
		Module="XRayAcquisitionDose"		Usage="U"	Condition="NeedModuleXRayAcquisitionDose"
		Module="XRayGeneration"				Usage="U"	Condition="NeedModuleXRayGeneration"
		Module="XRayFiltration"				Usage="U"	Condition="NeedModuleXRayFiltration"
		Module="XRayGrid"					Usage="U"	Condition="NeedModuleXRayGrid"
		Module="MammographyImage"			Usage="M"
		Module="OverlayPlane"				Usage="C"	Condition="NeedModuleOverlayPlane"
		Module="VOILUT"						Usage="C"	Condition="DXNeedModuleVOILUT"
		Module="ImageHistogram"				Usage="U"	Condition="NeedModuleImageHistogram"
		Module="AcquisitionContext"			Usage="M"
		Module="SOPCommon"					Usage="M"
		Module="CheckSingleFramePseudo"		Usage="M"
		Module="IHEMammoProfile"			Usage="M"
		Module="IHEMammoProfileWithoutPartialViewOption"		Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="MammographyImageForProcessingIHEMammoPartialViewOption"			Condition="MammographyImageForProcessingInstance"	Profile="IHEMammoPartialViewOption"
	InformationEntity="File"
		Module="FileMetaInformation"		Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"					Usage="M"
		Module="ClinicalTrialSubject"		Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"				Usage="M"
		Module="PatientStudy"				Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"			Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"				Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
		Module="DXSeries"					Usage="M"
		Module="MammographySeries"			Usage="M"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="U"	Condition="NeedModuleFrameOfReference"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="ContrastBolus"				Usage="U"	Condition="NeedModuleContrastBolus"
		Module="DisplayShutter"				Usage="U"	Condition="NeedModuleDisplayShutter"
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Intervention"				Usage="U"	Condition="NeedModuleIntervention"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="DXAnatomyImaged"			Usage="M"
		Module="DXImage"					Usage="M"
		Module="DXDetector"					Usage="M"
		Module="XRayCollimator"				Usage="U"	Condition="NeedModuleXRayCollimator"
		Module="DXPositioning"				Usage="U"	Condition="NeedModuleDXPositioning"
		Module="XRayTomographyAcquisition"	Usage="U"	Condition="NeedToCheckModuleXRayTomographyAcquisition"
		Module="XRayAcquisitionDose"		Usage="U"	Condition="NeedModuleXRayAcquisitionDose"
		Module="XRayGeneration"				Usage="U"	Condition="NeedModuleXRayGeneration"
		Module="XRayFiltration"				Usage="U"	Condition="NeedModuleXRayFiltration"
		Module="XRayGrid"					Usage="U"	Condition="NeedModuleXRayGrid"
		Module="MammographyImage"			Usage="M"
		Module="OverlayPlane"				Usage="C"	Condition="NeedModuleOverlayPlane"
		Module="VOILUT"						Usage="C"	Condition="DXNeedModuleVOILUT"
		Module="ImageHistogram"				Usage="U"	Condition="NeedModuleImageHistogram"
		Module="AcquisitionContext"			Usage="M"
		Module="SOPCommon"					Usage="M"
		Module="CheckSingleFramePseudo"		Usage="M"
		Module="IHEMammoProfile"			Usage="M"
		Module="IHEMammoProfileWithPartialViewOption"		Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="MammographyImageForPresentationIHEMammo"			Condition="MammographyImageForPresentationInstance"	Profile="IHEMammo"
	InformationEntity="File"
		Module="FileMetaInformation"		Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"					Usage="M"
		Module="ClinicalTrialSubject"		Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"				Usage="M"
		Module="PatientStudy"				Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"			Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"				Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
		Module="DXSeries"					Usage="M"
		Module="MammographySeries"			Usage="M"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="U"	Condition="NeedModuleFrameOfReference"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="ContrastBolus"				Usage="U"	Condition="NeedModuleContrastBolus"
		Module="DisplayShutter"				Usage="U"	Condition="NeedModuleDisplayShutter"
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Intervention"				Usage="U"	Condition="NeedModuleIntervention"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="DXAnatomyImaged"			Usage="M"
		Module="DXImage"					Usage="M"
		Module="DXDetector"					Usage="M"
		Module="XRayCollimator"				Usage="U"	Condition="NeedModuleXRayCollimator"
		Module="DXPositioning"				Usage="U"	Condition="NeedModuleDXPositioning"
		Module="XRayTomographyAcquisition"	Usage="U"	Condition="NeedToCheckModuleXRayTomographyAcquisition"
		Module="XRayAcquisitionDose"		Usage="U"	Condition="NeedModuleXRayAcquisitionDose"
		Module="XRayGeneration"				Usage="U"	Condition="NeedModuleXRayGeneration"
		Module="XRayFiltration"				Usage="U"	Condition="NeedModuleXRayFiltration"
		Module="XRayGrid"					Usage="U"	Condition="NeedModuleXRayGrid"
		Module="MammographyImage"			Usage="M"
		Module="OverlayPlane"				Usage="C"	Condition="NeedModuleOverlayPlane"
		Module="VOILUT"						Usage="C"	Condition="DXNeedModuleVOILUT"
		Module="ImageHistogram"				Usage="U"	Condition="NeedModuleImageHistogram"
		Module="AcquisitionContext"			Usage="M"
		Module="SOPCommon"					Usage="M"
		Module="CheckSingleFramePseudo"		Usage="M"
		Module="IHEMammoProfile"			Usage="M"
		Module="IHEMammoProfileWithoutPartialViewOption"		Usage="M"
		Module="IHEMammoProfileForPresentationOnly"		Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="MammographyImageForPresentationIHEMammoPartialViewOption"			Condition="MammographyImageForPresentationInstance"	Profile="IHEMammoPartialViewOption"
	InformationEntity="File"
		Module="FileMetaInformation"		Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"					Usage="M"
		Module="ClinicalTrialSubject"		Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"				Usage="M"
		Module="PatientStudy"				Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"			Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"				Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
		Module="DXSeries"					Usage="M"
		Module="MammographySeries"			Usage="M"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="U"	Condition="NeedModuleFrameOfReference"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="ContrastBolus"				Usage="U"	Condition="NeedModuleContrastBolus"
		Module="DisplayShutter"				Usage="U"	Condition="NeedModuleDisplayShutter"
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Intervention"				Usage="U"	Condition="NeedModuleIntervention"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="DXAnatomyImaged"			Usage="M"
		Module="DXImage"					Usage="M"
		Module="DXDetector"					Usage="M"
		Module="XRayCollimator"				Usage="U"	Condition="NeedModuleXRayCollimator"
		Module="DXPositioning"				Usage="U"	Condition="NeedModuleDXPositioning"
		Module="XRayTomographyAcquisition"	Usage="U"	Condition="NeedToCheckModuleXRayTomographyAcquisition"
		Module="XRayAcquisitionDose"		Usage="U"	Condition="NeedModuleXRayAcquisitionDose"
		Module="XRayGeneration"				Usage="U"	Condition="NeedModuleXRayGeneration"
		Module="XRayFiltration"				Usage="U"	Condition="NeedModuleXRayFiltration"
		Module="XRayGrid"					Usage="U"	Condition="NeedModuleXRayGrid"
		Module="MammographyImage"			Usage="M"
		Module="OverlayPlane"				Usage="C"	Condition="NeedModuleOverlayPlane"
		Module="VOILUT"						Usage="C"	Condition="DXNeedModuleVOILUT"
		Module="ImageHistogram"				Usage="U"	Condition="NeedModuleImageHistogram"
		Module="AcquisitionContext"			Usage="M"
		Module="SOPCommon"					Usage="M"
		Module="CheckSingleFramePseudo"		Usage="M"
		Module="IHEMammoProfile"			Usage="M"
		Module="IHEMammoProfileWithPartialViewOption"		Usage="M"
		Module="IHEMammoProfileForPresentationOnly"		Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="IntraoralImageForProcessing"			Condition="IntraoralImageForProcessingInstance"
	InformationEntity="File"
		Module="FileMetaInformation"		Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"					Usage="M"
		Module="ClinicalTrialSubject"		Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"				Usage="M"
		Module="PatientStudy"				Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"			Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"				Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
		Module="DXSeries"					Usage="M"
		Module="IntraoralSeries"			Usage="M"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="U"	Condition="NeedModuleFrameOfReference"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="ContrastBolus"				Usage="U"	Condition="NeedModuleContrastBolus"
		Module="DisplayShutter"				Usage="U"	Condition="NeedModuleDisplayShutter"
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Intervention"				Usage="U"	Condition="NeedModuleIntervention"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="DXAnatomyImaged"			Usage="M"
		Module="DXImage"					Usage="M"
		Module="DXDetector"					Usage="M"
		Module="XRayCollimator"				Usage="U"	Condition="NeedModuleXRayCollimator"
		Module="DXPositioning"				Usage="U"	Condition="NeedModuleDXPositioning"
		Module="XRayTomographyAcquisition"	Usage="U"	Condition="NeedToCheckModuleXRayTomographyAcquisition"
		Module="XRayAcquisitionDose"		Usage="U"	Condition="NeedModuleXRayAcquisitionDose"
		Module="XRayGeneration"				Usage="U"	Condition="NeedModuleXRayGeneration"
		Module="XRayFiltration"				Usage="U"	Condition="NeedModuleXRayFiltration"
		Module="XRayGrid"					Usage="U"	Condition="NeedModuleXRayGrid"
		Module="IntraoralImage"				Usage="M"
		Module="OverlayPlane"				Usage="C"	Condition="NeedModuleOverlayPlane"
		Module="VOILUT"						Usage="C"	Condition="DXNeedModuleVOILUT"
		Module="ImageHistogram"				Usage="U"	Condition="NeedModuleImageHistogram"
		Module="AcquisitionContext"			Usage="M"
		Module="SOPCommon"					Usage="M"
		Module="CheckSingleFramePseudo"		Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="IntraoralImageForPresentation"			Condition="IntraoralImageForPresentationInstance"
	InformationEntity="File"
		Module="FileMetaInformation"		Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"					Usage="M"
		Module="ClinicalTrialSubject"		Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"				Usage="M"
		Module="PatientStudy"				Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"			Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"				Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
		Module="DXSeries"					Usage="M"
		Module="IntraoralSeries"			Usage="M"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="U"	Condition="NeedModuleFrameOfReference"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="ContrastBolus"				Usage="U"	Condition="NeedModuleContrastBolus"
		Module="DisplayShutter"				Usage="U"	Condition="NeedModuleDisplayShutter"
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Intervention"				Usage="U"	Condition="NeedModuleIntervention"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="DXAnatomyImaged"			Usage="M"
		Module="DXImage"					Usage="M"
		Module="DXDetector"					Usage="M"
		Module="XRayCollimator"				Usage="U"	Condition="NeedModuleXRayCollimator"
		Module="DXPositioning"				Usage="U"	Condition="NeedModuleDXPositioning"
		Module="XRayTomographyAcquisition"	Usage="U"	Condition="NeedToCheckModuleXRayTomographyAcquisition"
		Module="XRayAcquisitionDose"		Usage="U"	Condition="NeedModuleXRayAcquisitionDose"
		Module="XRayGeneration"				Usage="U"	Condition="NeedModuleXRayGeneration"
		Module="XRayFiltration"				Usage="U"	Condition="NeedModuleXRayFiltration"
		Module="XRayGrid"					Usage="U"	Condition="NeedModuleXRayGrid"
		Module="IntraoralImage"				Usage="M"
		Module="OverlayPlane"				Usage="C"	Condition="NeedModuleOverlayPlane"
		Module="VOILUT"						Usage="C"	Condition="DXNeedModuleVOILUT"
		Module="ImageHistogram"				Usage="U"	Condition="NeedModuleImageHistogram"
		Module="AcquisitionContext"			Usage="M"
		Module="SOPCommon"					Usage="M"
		Module="CheckSingleFramePseudo"		Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="IntraoralImageForPresentationDentalMedia"			Condition="IntraoralImageForPresentationInstance"	Profile="Dental"
	InformationEntity="File"
		Module="FileMetaInformation"		Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"					Usage="M"
		Module="ClinicalTrialSubject"		Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"				Usage="M"
		Module="PatientStudy"				Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"			Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"				Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
		Module="DXSeries"					Usage="M"
		Module="IntraoralSeries"			Usage="M"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="U"	Condition="NeedModuleFrameOfReference"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="ContrastBolus"				Usage="U"	Condition="NeedModuleContrastBolus"
		Module="DisplayShutter"				Usage="U"	Condition="NeedModuleDisplayShutter"
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Intervention"				Usage="U"	Condition="NeedModuleIntervention"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="DXAnatomyImaged"			Usage="M"
		Module="DXImage"					Usage="M"
		Module="DXDetector"					Usage="M"
		Module="XRayCollimator"				Usage="U"	Condition="NeedModuleXRayCollimator"
		Module="DXPositioning"				Usage="U"	Condition="NeedModuleDXPositioning"
		Module="XRayTomographyAcquisition"	Usage="U"	Condition="NeedToCheckModuleXRayTomographyAcquisition"
		Module="XRayAcquisitionDose"		Usage="U"	Condition="NeedModuleXRayAcquisitionDose"
		Module="XRayGeneration"				Usage="U"	Condition="NeedModuleXRayGeneration"
		Module="XRayFiltration"				Usage="U"	Condition="NeedModuleXRayFiltration"
		Module="XRayGrid"					Usage="U"	Condition="NeedModuleXRayGrid"
		Module="IntraoralImage"				Usage="M"
		Module="OverlayPlane"				Usage="C"	Condition="NeedModuleOverlayPlane"
		Module="VOILUT"						Usage="C"	Condition="DXNeedModuleVOILUT"
		Module="ImageHistogram"				Usage="U"	Condition="NeedModuleImageHistogram"
		Module="AcquisitionContext"			Usage="M"
		Module="SOPCommon"					Usage="M"
		Module="CheckSingleFramePseudo"		Usage="M"
		Module="DentalImageOnMediaProfile"	Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="DXImageForPresentationDentalMedia"			Condition="DXImageForPresentationInstance"	Profile="Dental"
	InformationEntity="File"
		Module="FileMetaInformation"		Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"					Usage="M"
		Module="ClinicalTrialSubject"		Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"				Usage="M"
		Module="PatientStudy"				Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"			Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"				Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
		Module="DXSeries"					Usage="M"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="U"	Condition="NeedModuleFrameOfReference"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="ContrastBolus"				Usage="U"	Condition="NeedModuleContrastBolus"
		Module="DisplayShutter"				Usage="U"	Condition="NeedModuleDisplayShutter"
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Intervention"				Usage="U"	Condition="NeedModuleIntervention"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="DXAnatomyImaged"			Usage="M"
		Module="DXImage"					Usage="M"
		Module="DXDetector"					Usage="M"
		Module="XRayCollimator"				Usage="U"	Condition="NeedModuleXRayCollimator"
		Module="DXPositioning"				Usage="U"	Condition="NeedModuleDXPositioning"
		Module="XRayTomographyAcquisition"	Usage="U"	Condition="NeedToCheckModuleXRayTomographyAcquisition"
		Module="XRayAcquisitionDose"		Usage="U"	Condition="NeedModuleXRayAcquisitionDose"
		Module="XRayGeneration"				Usage="U"	Condition="NeedModuleXRayGeneration"
		Module="XRayFiltration"				Usage="U"	Condition="NeedModuleXRayFiltration"
		Module="XRayGrid"					Usage="U"	Condition="NeedModuleXRayGrid"
		Module="OverlayPlane"				Usage="C"	Condition="NeedModuleOverlayPlane"
		Module="VOILUT"						Usage="C"	Condition="DXNeedModuleVOILUT"
		Module="ImageHistogram"				Usage="U"	Condition="NeedModuleImageHistogram"
		Module="AcquisitionContext"			Usage="M"
		Module="SOPCommon"					Usage="M"
		Module="CheckSingleFramePseudo"		Usage="M"
		Module="DentalImageOnMediaProfile"	Usage="M"
	InformationEntityEnd
CompositeIODEnd
