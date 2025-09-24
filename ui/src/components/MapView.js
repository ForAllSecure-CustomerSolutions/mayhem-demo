import React, { useEffect, useState } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import 'leaflet.markercluster/dist/MarkerCluster.css';
import 'leaflet.markercluster/dist/MarkerCluster.Default.css';
import 'leaflet.markercluster';
import axios from 'axios';
import {
  useReactTable,
  getCoreRowModel,
  flexRender,
} from '@tanstack/react-table';

// Fix for default marker icons
delete L.Icon.Default.prototype._getIconUrl;

L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png'
});

// Component to handle map bounds updates
const MapBounds = ({ locations }) => {
  const map = useMap();
  
  useEffect(() => {
    if (locations && locations.length > 0) {
      const bounds = locations
        .filter(loc => loc.latitude !== 0 && loc.longitude !== 0)
        .map(loc => [loc.latitude, loc.longitude]);
      
      if (bounds.length > 0) {
        map.fitBounds(bounds);
      }
    }
  }, [locations, map]);
  
  return null;
};

const MapView = ({ isAuthenticated, username, password }) => {
  const [locations, setLocations] = useState([]);

  useEffect(() => {
    const fetchLocations = async () => {
      if (!isAuthenticated) {
        setLocations([]);
        return;
      }
      
      try {
        // Proxy will redirect to API server.
        const response = await axios.get('/locations', {
          auth: {
            username: username,
            password: password
          }
        });
        setLocations(response.data.locations);
      } catch (error) {
        console.error("Error fetching locations:", error);
      }
    };

    fetchLocations();
  }, [isAuthenticated, username, password]);

  const columns = React.useMemo(
    () => [
      {
        header: 'Latitude',
        accessorKey: 'latitude',
      },
      {
        header: 'Longitude',
        accessorKey: 'longitude',
      }
    ],
    []
  );

  const data = React.useMemo(() => locations, [locations]);

  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
  });

  return (
    <div>
      {!isAuthenticated && (
        <div style={{ textAlign: 'center', padding: '10px', backgroundColor: '#f0f0f0' }}>
          Please log in to view GPS telemetry data
        </div>
      )}
      <div style={{ height: "600px", width: "100%" }}>
        <MapContainer center={[0, 0]} zoom={2} style={{ height: "100%", width: "100%" }}>
          <TileLayer
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          />
          <MapBounds locations={locations} />
          {locations.map((loc, index) => (
            <Marker key={index} position={[loc.latitude, loc.longitude]}>
              <Popup>
                Latitude: {loc.latitude}, Longitude: {loc.longitude}
              </Popup>
            </Marker>
          ))}
        </MapContainer>
      </div>
      <div className="table-container">
        <table className="telemetry-table">
          <thead>
            {table.getHeaderGroups().map(headerGroup => (
              <tr key={headerGroup.id}>
                {headerGroup.headers.map(header => (
                  <th key={header.id}>
                    {flexRender(header.column.columnDef.header, header.getContext())}
                  </th>
                ))}
              </tr>
            ))}
          </thead>
          <tbody>
            {table.getRowModel().rows.map(row => (
              <tr key={row.id}>
                {row.getVisibleCells().map(cell => (
                  <td key={cell.id}>
                    {flexRender(cell.column.columnDef.cell, cell.getContext())}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default MapView;