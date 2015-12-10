//
//  MapVC.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 10/31/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import MapKit
import UIKit

enum ChicagoBoundary : String {
    case City = "City"
    case Neighborhood = "Neighborhood"
    case None = "None"
}

protocol MapVCDelegate {
    func mapVC(mapVC: MapVC, showDetailVCForAnnotation annotation:MKAnnotation)
}

class MapVC: UIViewController, MKMapViewDelegate {

    var delegate: MapVCDelegate?

    var cityBoundary: ChicagoBoundary = .City
    var boundaryOverlays: [MKPolygon] = []

    var crimes:Array<Report> = []
    var crimeBuffer:Array<Report> = []

    var schools:Array<School> = []
    var schoolHeatMapAttrib: SchoolAttribute?
    var schoolRadius:Double = 1609.0 // 1609 meters = 1 mile

    var selectedSchool: School?
    var selectedSchoolOverlay:MKCircle?

    var oldRegion: MKCoordinateRegion?

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.showsScale = true

        // set initial mapView position
        let center = CLLocationCoordinate2DMake(41.8570092871228, -87.6975366951543)
        let span = MKCoordinateSpanMake(0.4, 0.7)
        mapView.setRegion(MKCoordinateRegionMake(center, span), animated: false)

        showBoundaryWithDataSet("chicago_boundaries")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let gradientView:UIView = UIView(frame: CGRect(x: 0, y: view.frame.size.height-30, width: 400, height: 30))
        gradientView.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.1)
        gradLayer?.frame = gradientView.bounds
        gradientView.layer.insertSublayer(gradLayer!, above: view.layer)

        view.insertSubview(gradientView, aboveSubview: view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Helper

    func crimesArroundLocation(location: CLLocationCoordinate2D) -> Int {
        let thisLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        var count = 0

        crimes.forEach {
            let crimeLocation = CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            if schoolRadius*1609.0 >= thisLocation.distanceFromLocation(crimeLocation) {
                count++
            }
        }

        return count
    }

    func addReports(reports: Array<Report>) {
        clearReports()

        crimes += reports
        evaluateBuffer()
    }

    func clearReports() {
        mapView.removeAnnotations(crimes)
        crimeBuffer.removeAll()
        crimes.removeAll()
    }

    func zoomLevelForRegion(region: MKCoordinateRegion) -> Int {
        let MERCATOR_RADIUS = 85445659.44705395
        return Int(21.0 - round(log2(region.span.longitudeDelta * MERCATOR_RADIUS * M_PI / Double(180.0 * mapView.bounds.size.width))));
    }

    func evaluateBuffer() {
        if crimes.count == 0 { return }
        var reportsOutOfRegion: [Report] = []
        var reportsInRegion: [Report] = []
        if oldRegion != nil {
            let newRegion = mapView.region
            if zoomLevelForRegion(newRegion) < zoomLevelForRegion(oldRegion!) {
                // Zoom out
                print("Zoomed out")
                mapView.removeAnnotations(crimeBuffer)
                crimeBuffer.removeAll()
            }
        }

        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            self.crimeBuffer.forEach {
                let pointForCrime = MKMapPointForCoordinate($0.coordinate)
                if !MKMapRectContainsPoint(self.mapView.visibleMapRect, pointForCrime) {
                    reportsOutOfRegion += [$0]
                    self.crimeBuffer.removeAtIndex(self.crimeBuffer.indexOf($0)!)
                }
            }

            for cr in self.crimes {
                if self.crimeBuffer.count >= 800 {
                    break
                }

                let pointForCrime = MKMapPointForCoordinate(cr.coordinate)
                if MKMapRectContainsPoint(self.mapView.visibleMapRect, pointForCrime) {
                    reportsInRegion += [cr]
                    self.crimeBuffer += [cr]
                }
            }

            dispatch_async(dispatch_get_main_queue()) {
                self.mapView.removeAnnotations(reportsOutOfRegion)
                self.mapView.addAnnotations(reportsInRegion)
            }
        }
    }

    func addSchools(schools: Array<School>) {
        clearSchools()

        self.schools += schools
        mapView.addAnnotations(schools)
    }

    func clearSchools() {
        // remove overlays
        if selectedSchoolOverlay != nil {
            mapView.removeOverlay(selectedSchoolOverlay!)
            selectedSchoolOverlay = nil
        }

        mapView.removeAnnotations(schools)
        schools.removeAll()
    }

    func clearBoundaries() {
        mapView.removeOverlays(boundaryOverlays)
        boundaryOverlays.removeAll()
    }

    func showBoundaryWithDataSet(set: String) {
        clearBoundaries()

        let path = NSBundle.mainBundle().pathForResource(set, ofType: "json")
        let json = JSON(data: NSData(contentsOfFile: path!)!)

        let timeStart:NSDate = NSDate()
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            for (_, sJson) in json {
                var points:[CLLocationCoordinate2D] = []
                for (_, ssJson) in sJson["the_geom"]["coordinates"][0][0] {
                    points += [CLLocationCoordinate2DMake(ssJson[1].double!, ssJson[0].double!)]
                }

                self.boundaryOverlays += [MKPolygon(coordinates: &points, count: points.count)]
            }

            dispatch_async(dispatch_get_main_queue()) {
                self.mapView.addOverlays(self.boundaryOverlays)

                let interval:NSTimeInterval = NSDate().timeIntervalSinceDate(timeStart)
                print("Boundary load and plot finished in \(interval) seconds")
            }
        }
    }
    
    func addRadiusCircleForSchool(school: School){
        let circle = MKCircle(centerCoordinate: school.coordinate, radius: (Double(schoolRadius))*1609.0 as CLLocationDistance)
        let lat = circle.coordinate.latitude
        let lon = circle.coordinate.longitude
        if lat == selectedSchoolOverlay?.coordinate.latitude &&
            lon == selectedSchoolOverlay?.coordinate.longitude {
            // overlay is already on screen
            mapView.removeOverlay(selectedSchoolOverlay!)

            selectedSchool = nil
            selectedSchoolOverlay = nil
            return
        }

        if selectedSchoolOverlay != nil {
            mapView.removeOverlay(selectedSchoolOverlay!)
        }

        mapView.addOverlay(circle)
        selectedSchool = school
        selectedSchoolOverlay = circle
    }

    func changeSelectCircleRadius(radius: Double) {
        if selectedSchoolOverlay != nil {
            let newCircle = MKCircle(centerCoordinate: selectedSchool!.coordinate, radius: radius*1609.0 as CLLocationDistance)
            mapView.addOverlay(newCircle)

            mapView.removeOverlay(selectedSchoolOverlay!)
            selectedSchoolOverlay = newCircle
        }
    }

    // MARK: IBActions

    @IBAction func tappedBoundaryButton(sender: UIButton) {
        cityBoundary = { () -> ChicagoBoundary in
            switch self.cityBoundary {
            case .City:
                showBoundaryWithDataSet("chicago_boundaries_neighborhood")
                return .Neighborhood

            case .Neighborhood:
                clearBoundaries()
                return .None

            case .None:
                showBoundaryWithDataSet("chicago_boundaries")
                return .City
            }
        }()

        sender.setTitle(cityBoundary.rawValue, forState: .Normal)
    }

    @IBAction func tappedMapTypeButton(sender: UIButton) {
        let nextType = MKMapType(rawValue: mapView.mapType.rawValue + UInt(1))!
        mapView.mapType = mapView.mapType == .HybridFlyover ? .Standard : nextType

        switch mapView.mapType {
        case .Standard:
            sender.setTitle("Standard", forState: .Normal)
            break

        case .Satellite:
            sender.setTitle("Satellite", forState: .Normal)
            break

        case .Hybrid:
            sender.setTitle("Hybrid", forState: .Normal)
            break

        case .SatelliteFlyover:
            sender.setTitle("Satellite Flyover", forState: .Normal)
            break

        case .HybridFlyover:
            sender.setTitle("Hybrid Flyover", forState: .Normal)
            break
        }
    }

    // MARK: MKMapViewDelegate

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is Report:
            return (annotation as! Report).mapAnnotationView()

        case is School:
            if schoolHeatMapAttrib != nil {
                (annotation as! School).setAttribute(SelectedAttribute: schoolHeatMapAttrib!)
            }
            return (annotation as! School).mapAnnotationView()
            
        default:
            return nil
        }
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView annotView: MKAnnotationView) {
        delegate?.mapVC(self, showDetailVCForAnnotation: annotView.annotation!)
        let anno:MKAnnotation = annotView.annotation!
        
        if anno is School {
            addRadiusCircleForSchool(annotView.annotation as! School)
        }

        mapView.deselectAnnotation(anno, animated: false)
    }

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if let poly = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(polygon: poly)
            renderer.fillColor = UIColor.grayColor().colorWithAlphaComponent(0.1)
            renderer.strokeColor = UIColor.blackColor()
            renderer.lineWidth = 2

            return renderer
        }
        else if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.redColor()
            circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
            circle.lineWidth = 1

            return circle
        }
        
        return MKOverlayRenderer()
    }

    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        oldRegion = mapView.region
    }

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        evaluateBuffer()

        oldRegion = nil
    }
}
