import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { GovernanceGate } from './components/GovernanceGate';
import { MapView } from './screens/MapView';

export default function App() {
  return (
    <GovernanceGate>
      <BrowserRouter>
        <Routes>
          <Route path="*" element={<MapView />} />
        </Routes>
      </BrowserRouter>
    </GovernanceGate>
  );
}
